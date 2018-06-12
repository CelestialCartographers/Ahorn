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

# The point the entity will be drawn relative too
# Make sure it returns in Int32/64
function entityTranslation(entity::Maple.Entity)
    return (
        floor(Int, get(entity.data, "x", 0)),
        floor(Int, get(entity.data, "y", 0))
    )
end

function renderEntity(ctx::Cairo.CairoContext, layer::Layer, entity::Maple.Entity, room::Maple.Room; alpha::Number=1)
    Cairo.save(ctx)

    # Set global alpha here, passing alpha to the entity renderer is not sane
    setGlobalAlpha!(alpha)

    res = eventToModules(loadedEntities, "renderAbs", ctx, entity) ||
          eventToModules(loadedEntities, "renderAbs", layer, entity) || 
          eventToModules(loadedEntities, "renderAbs", ctx, entity, room) ||
          eventToModules(loadedEntities, "renderAbs", layer, entity, room)

    translate(ctx, entityTranslation(entity)...)
    res |= eventToModules(loadedEntities, "render", ctx, entity) ||
          eventToModules(loadedEntities, "render", layer, entity) || 
          eventToModules(loadedEntities, "render", ctx, entity, room) ||
          eventToModules(loadedEntities, "render", layer, entity, room)
    
    # Reset global alpha again
    setGlobalAlpha!(1)
    restore(ctx)

    if !res
        debug.log("Couldn't render entity '$(entity.name)' in room '$(room.name)'", "DRAWING_ENTITY_MISSING")
    end
end

function renderEntitySelection(ctx::Cairo.CairoContext, layer::Layer, entity::Maple.Entity, room::Maple.Room; alpha::Number=1)
    Cairo.save(ctx)

    # Set global alpha here, passing alpha to the entity renderer is not sane
    setGlobalAlpha!(alpha)
    
    res = eventToModules(loadedEntities, "renderSelectedAbs", ctx, entity) ||
        eventToModules(loadedEntities, "renderSelectedAbs", layer, entity) || 
        eventToModules(loadedEntities, "renderSelectedAbs", ctx, entity, room) ||
        eventToModules(loadedEntities, "renderSelectedAbs", layer, entity, room)

    translate(ctx, entityTranslation(entity)...)
    res |= eventToModules(loadedEntities, "renderSelected", ctx, entity) ||
        eventToModules(loadedEntities, "renderSelected", layer, entity) || 
        eventToModules(loadedEntities, "renderSelected", ctx, entity, room) ||
        eventToModules(loadedEntities, "renderSelected", layer, entity, room)

    # Reset global alpha again
    setGlobalAlpha!(1)
    restore(ctx)
end

function minimumSize(entity::Main.Maple.Entity)
    if get(debug.config, "IGNORE_MINIMUM_SIZE", false)
        return 0, 0
    end

    selectionRes = Main.eventToModules(Main.loadedEntities, "minimumSize", entity)
    
    if isa(selectionRes, Tuple)
        success, width, height = selectionRes

        if success
            return width, height
        end
    end

    return 0, 0
end

function canResize(entity::Main.Maple.Entity)
    if get(debug.config, "IGNORE_CAN_RESIZE", false)
        return true, true
    end

    selectionRes = Main.eventToModules(Main.loadedEntities, "resizable", entity)
    
    if isa(selectionRes, Tuple)
        success, vertical, horizontal = selectionRes

        if success
            return vertical, horizontal
        end
    end

    return false, false
end

function nodeLimits(entity::Main.Maple.Entity)
    selectionRes = Main.eventToModules(Main.loadedEntities, "nodeLimits", entity)
    
    if isa(selectionRes, Tuple)
        success, least, most = selectionRes

        if success
            return least, most
        end
    end

    return 0, 0
end

function registerPlacements!(placements::Dict{String, EntityPlacement}, loaded::Array{String, 1})
    empty!(placements)

    for modul in loaded
        if hasModuleField(modul, "placements")
            merge!(placements, getModuleField(modul, "placements"))
        end
    end
end

function generateEntity(ep::EntityPlacement, x::Integer, y::Integer, nx::Integer=x + 8, ny::Integer=y + 8)
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

    ep.finalizer(entity)

    return entity
end

loadedEntities = joinpath.("entities", readdir(@abs "entities"))
loadModule.(loadedEntities)

entityPlacements = Dict{String, EntityPlacement}()
registerPlacements!(entityPlacements, loadedEntities)