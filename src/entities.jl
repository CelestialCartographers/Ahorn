include("tile_entity.jl")

# Use the Maple function
# Then set the data from the placements (such as setting fields IE winged for strawberries)
struct EntityPlacement
    func::Function
    placement::String
    data::Dict{String, Any}
    finalizer::Function

    EntityPlacement(func::Function, placement::String="point", data::Dict{String, Any}=Dict{String, Any}(), finalizer::Function=e -> e) = new(func, placement, data, finalizer)
end

entityNameLookup = Dict{String, String}()

# The point the entity will be drawn relative too
# Make sure it returns in Int32/64
function entityTranslation(entity::Maple.Entity)
    return (
        floor(Int, get(entity.data, "x", 0)),
        floor(Int, get(entity.data, "y", 0))
    )
end

function renderEvent(fn::String, func::String, args...)
    if !haskey(loadedModules, fn)
        return false
    end

    res = eventToModule(fn, func, args...)

    return !isa(res, Void) && res
end

function attemptEntityRender(ctx::Cairo.CairoContext, layer::Layer, entity::Maple.Entity, room::Maple.Room, fn::String)
    Cairo.save(ctx)

    res = renderEvent(fn, "renderAbs", ctx, entity) ||
        renderEvent(fn, "renderAbs", layer, entity) || 
        renderEvent(fn, "renderAbs", ctx, entity, room) ||
        renderEvent(fn, "renderAbs", layer, entity, room)

    translate(ctx, entityTranslation(entity)...)
    res |= renderEvent(fn, "render", ctx, entity) ||
        renderEvent(fn, "render", layer, entity) || 
        renderEvent(fn, "render", ctx, entity, room) ||
        renderEvent(fn, "render", layer, entity, room)

    Cairo.restore(ctx)

    return res
end

function renderEntity(ctx::Cairo.CairoContext, layer::Layer, entity::Maple.Entity, room::Maple.Room; alpha::Number=1)
    success = false

    # Set global alpha here, passing alpha to the entity renderer is not sane
    setGlobalAlpha!(alpha)

    if haskey(entityNameLookup, entity.name)
        fn = entityNameLookup[entity.name]
        success = attemptEntityRender(ctx, layer, entity, room, fn)

    else
        for fn in loadedEntities
            success = attemptEntityRender(ctx, layer, entity, room, fn)

            if success
                entityNameLookup[entity.name] = fn

                break
            end
        end
    end

    # Reset global alpha again
    setGlobalAlpha!(1)

    if !success
        debug.log("Couldn't render entity '$(entity.name)' in room '$(room.name)'", "DRAWING_ENTITY_MISSING")
    end
end

function attemptEntitySelectionRender(ctx::Cairo.CairoContext, layer::Layer, entity::Maple.Entity, room::Maple.Room, fn::String)
    Cairo.save(ctx)

    eventToModule(fn, "renderSelectedAbs", ctx, entity)
    eventToModule(fn, "renderSelectedAbs", layer, entity) 
    eventToModule(fn, "renderSelectedAbs", ctx, entity, room)
    eventToModule(fn, "renderSelectedAbs", layer, entity, room)

    translate(ctx, entityTranslation(entity)...)
    eventToModule(fn, "renderSelected", ctx, entity)
    eventToModule(fn, "renderSelected", layer, entity) 
    eventToModule(fn, "renderSelected", ctx, entity, room)
    eventToModule(fn, "renderSelected", layer, entity, room)

    Cairo.restore(ctx)
end

function renderEntitySelection(ctx::Cairo.CairoContext, layer::Layer, entity::Maple.Entity, room::Maple.Room; alpha::Number=1)    
    # Set global alpha here, passing alpha to the entity renderer is not sane
    setGlobalAlpha!(alpha)

    # Selection renders are less strict on returning if they have been handled
    # Assume that we can use the same filename as for `render` call, or all other otherwise
    if haskey(entityNameLookup, entity.name)
        fn = entityNameLookup[entity.name]
        attemptEntitySelectionRender(ctx, layer, entity, room, fn)

    else
        for fn in loadedEntities
            attemptEntitySelectionRender(ctx, layer, entity, room, fn)
        end
    end

    # Reset global alpha again
    setGlobalAlpha!(1)
end

function entityPropertyQuery(entity::Maple.Entity, func::String)
    if haskey(entityNameLookup, entity.name)
        return eventToModule(entityNameLookup[entity.name], func, entity)

    else
        return eventToModules(loadedEntities, func, entity)
    end
end

function minimumSize(entity::Maple.Entity)
    if get(debug.config, "IGNORE_MINIMUM_SIZE", false)
        return 0, 0
    end
    
    sizeRes = entityPropertyQuery(entity, "minimumSize")

    if isa(sizeRes, Tuple)
        success, width, height = sizeRes

        if success
            return width, height
        end
    end

    return 0, 0
end

function canResize(entity::Maple.Entity)
    if get(debug.config, "IGNORE_CAN_RESIZE", false)
        return true, true
    end

    resizeRes = entityPropertyQuery(entity, "resizable")
    
    if isa(resizeRes, Tuple)
        success, vertical, horizontal = resizeRes

        if success
            return vertical, horizontal
        end
    end

    return false, false
end

function nodeLimits(entity::Maple.Entity)
    nodeRes = entityPropertyQuery(entity, "nodeLimits")
    
    if isa(nodeRes, Tuple)
        success, least, most = nodeRes

        if success
            return least, most
        end
    end

    return 0, 0
end

function editingOptions(entity::Maple.Entity)
    optionsRes = entityPropertyQuery(entity, "editingOptions")
    
    if isa(optionsRes, Tuple)
        success, options = optionsRes

        if success
            return success, options
        end
    end

    return false, Dict{String, Any}()
end

function registerPlacements!(placements::Dict{String, EntityPlacement}, loaded::Array{String, 1})
    empty!(placements)

    for modul in loaded
        if hasModuleField(modul, "placements")
            merge!(placements, getModuleField(modul, "placements"))
        end
    end
end

function callFinalizer(map::Maple.Map, room::Room, ep::EntityPlacement, target::Union{Maple.Entity, Maple.Trigger})
    argsList = Tuple[
        (target, map, room),
        (target, room),
        (target,)
    ]

    for args in argsList
        if applicable(ep.finalizer, args...)
            return ep.finalizer(args...)
        end
    end
end

function generateEntity(map::Maple.Map, room::Room, ep::EntityPlacement, x::Integer, y::Integer, nx::Integer=x + 8, ny::Integer=y + 8)
    # Create the default entity with the correct coords, then merge the extra data in
    entity = ep.func(x, y)
    merge!(entity.data, ep.data)

    if ep.placement == "rectangle"
        rect = selectionRectangle(x, y, nx, ny)

        resizeW, resizeH = canResize(entity)
        minW, minH = minimumSize(entity)
        
        w = resizeW? max(minW, rect.w - 1) : minW
        h = resizeH? max(minH, rect.h - 1) : minH
        entity.data["x"], entity.data["y"] = rect.x, rect.y
        merge!(entity.data, Dict("width" => w, "height" => h))

    elseif ep.placement == "line"
        merge!(entity.data, Dict("nodes" => [(nx, ny)]))
    end

    callFinalizer(map, room, ep, entity)

    return entity
end

function entityConfigOptions(entity::Union{Maple.Entity, Maple.Trigger}, ignores::Array{String, 1}=String[])
    addedNodes = false
    res = ConfigWindow.Option[]

    success, options = editingOptions(entity)
    horizontalAllowed, verticalAllowed = canResize(entity)
    nodeRange = nodeLimits(entity)

    for (attr, value) in entity.data
        keyOptions = get(options, attr, nothing)

        if !horizontalAllowed && attr == "width" || !verticalAllowed && attr == "height"
            continue
        end

        # Always ignore these, regardless of ignore argument
        if attr == "originX" || attr == "originY"
            continue
        end

        if attr in ignores
            continue
        end

        if isa(value, Bool) || isa(value, Char) || isa(value, String)
            push!(res, ConfigWindow.Option(humanizeVariableName(attr), typeof(value), value, options=keyOptions, dataName=attr))

        elseif isa(value, Integer)
            push!(res, ConfigWindow.Option(humanizeVariableName(attr), Int64, Int64(value), options=keyOptions, dataName=attr))

        elseif isa(value, Real)
            push!(res, ConfigWindow.Option(humanizeVariableName(attr), Float64, Float64(value), options=keyOptions, dataName=attr))

        elseif attr == "nodes"
            push!(res, ConfigWindow.Option("Node X;Node Y", Array{Tuple{Int64, Int64}, 1}, value, options=keyOptions, dataName=attr, rowCount=nodeRange))
            addedNodes = true
        end
    end

    if !addedNodes && nodeRange[2] != 0 && !("nodes" in ignores)
        push!(res, ConfigWindow.Option("Node X;Node Y", Array{Tuple{Int64, Int64}, 1}, Tuple{Int, Int}[], dataName="nodes", rowCount=nodeRange))
    end

    return res
end

loadedEntities = joinpath.(abs"entities", readdir(abs"entities"))
loadModule.(loadedEntities)
entityPlacements = Dict{String, EntityPlacement}()