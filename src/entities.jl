include("tile_entity.jl")

# Use the Maple function
# Then set the data from the placements (such as setting fields IE winged for strawberries)
struct EntityPlacement
    func::Union{Function, Type}
    placement::String
    data::Dict{String, Any}
    finalizer::Union{Function, Nothing}

    function EntityPlacement(func::Union{Function, Type}, placement::String="point", data::Dict{String, Any}=Dict{String, Any}(), finalizer::Union{Function, Nothing}=nothing)
        return new(func, placement, data, finalizer)
    end
end

const PlacementDict = Dict{String, EntityPlacement}

const entityNameLookup = Dict{String, String}()

# The point the entity will be drawn relative too
# Make sure it returns in Int32/64
function position(entity::Maple.Entity)::Tuple{Int, Int}
    return floor(Int, entity.x), floor(Int, entity.y)
end

function attemptEntityRender(ctx::Cairo.CairoContext, layer::Layer, entity::Maple.Entity, room::Maple.Room)
    if ctx.ptr != C_NULL
        Cairo.save(ctx)

        res = renderAbs(ctx, entity) != false||
            renderAbs(ctx, entity, room) != false

        if !res
            x, y = position(entity)

            translate(ctx, x, y)
            res |= render(ctx, entity) != false ||
                render(ctx, entity, room) != false
        end

        Cairo.restore(ctx)

        return res
    end

    return false
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity)
    return false
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    return false
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity)
    return false
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    return false
end

function renderEntity(ctx::Cairo.CairoContext, layer, entity, room; alpha=1.0)
    success = false

    # Set global alpha here, passing alpha to the entity renderer is not sane
    setGlobalAlpha!(alpha)

    success = attemptEntityRender(ctx, layer, entity, room)

    # Reset global alpha again
    setGlobalAlpha!(1.0)

    if !success
        debug.log("Couldn't render entity '$(entity.name)' in room '$(room.name)'", "DRAWING_ENTITY_MISSING")
    end
end

function renderSelected(ctx::Cairo.CairoContext, entity::Maple.Entity)
    return false
end

function renderSelected(ctx::Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    return false
end

function renderSelectedAbs(ctx::Cairo.CairoContext, entity::Maple.Entity)
    return false
end

function renderSelectedAbs(ctx::Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    return false
end

function attemptEntitySelectionRender(ctx::Cairo.CairoContext, layer::Layer, entity::Maple.Entity, room::Maple.Room)
    if ctx.ptr != C_NULL
        Cairo.save(ctx)

        res = renderSelectedAbs(ctx, entity) != false ||
            renderSelectedAbs(ctx, entity, room) != false

        if !res
            x, y = position(entity)

            translate(ctx, x, y)
            res |=
                renderSelected(ctx, entity) != false ||
                renderSelected(ctx, entity, room) != false
        end

        Cairo.restore(ctx)

        return res
    end

    return false
end

function renderEntitySelection(ctx::Cairo.CairoContext, layer::Layer, entity::Maple.Entity, room::Maple.Room; alpha=1.0)    
    # Set global alpha here, passing alpha to the entity renderer is not sane
    setGlobalAlpha!(alpha)

    success = attemptEntitySelectionRender(ctx, layer, entity, room)

    # Reset global alpha again
    setGlobalAlpha!(1.0)
end

# Helper function to respect debug option
function minimumSizeWrapper(target::Union{Maple.Entity, Maple.Trigger})
    if get(debug.config, "IGNORE_MINIMUM_SIZE", false)
        return 0, 0
    end

    return minimumSize(target)
end

# Helper function to respect debug option
function canResizeWrapper(target::Union{Maple.Entity, Maple.Trigger})
    if get(debug.config, "IGNORE_CAN_RESIZE", false)
        return true, true
    end

    return resizable(target)
end

minimumSize(entity::Maple.Entity) = 8, 8
resizable(entity::Maple.Entity) = false, false

nodeLimits(entity::Maple.Entity) = 0, 0

editingOptions(entity::Maple.Entity) = Dict{String, Any}()
editingOrder(entity::Maple.Entity) = String["x", "y", "width", "height"]
editingIgnored(entity::Maple.Entity, multiple::Bool=false) = multiple ? String["x", "y", "width", "height", "nodes"] : String[]

deleted(entity::Maple.Entity, node::Int) = nothing

moved(entity::Maple.Entity) = nothing
moved(entity::Maple.Entity, x::Int, y::Int) = nothing

resized(entity::Maple.Entity) = nothing
resized(entity::Maple.Entity, width::Int, height::Int) = nothing

flipped(entity::Maple.Entity, horizontal::Bool) = nothing

rotated(entity::Maple.Entity, steps::Int) = nothing

function registerPlacements!(placements::PlacementDict, loaded::Array{String, 1})
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

function updateEntityPosition!(target::Union{Entity, Trigger}, ep::EntityPlacement, map::Maple.Map, room::Room, x::Int, y::Int, nx::Int=x + 8, ny::Int=y + 8)
    merge!(target.data, ep.data)

    if ep.placement == "point"
        target.x = x
        target.y = y

    elseif ep.placement == "rectangle"
        rect = selectionRectangle(x, y, nx, ny)

        resizeHorizontal, resizeVertical = canResizeWrapper(target)
        minWidth, minHeight = minimumSizeWrapper(target)

        target.x = rect.x
        target.y = rect.y

        if resizeHorizontal
            target.width = max(minWidth, rect.w - 1)
        end

        if resizeVertical
            target.height = max(minHeight, rect.h - 1)
        end

    elseif ep.placement == "line"
        target.x = x
        target.y = y

        target.nodes = Tuple{Integer, Integer}[(nx, ny)]
    end

    if ep.finalizer !== nothing
        callFinalizer(map, room, ep, target)
    end

    return target
end

function generateEntity(map::Maple.Map, room::Room, ep::EntityPlacement, x::Int, y::Int, nx::Int=x + 8, ny::Int=y + 8)
    target = ep.func(x, y)

    return updateEntityPosition!(target, ep, map, room, x, y, nx, ny)
end

function updateCachedEntityPosition!(cache::Dict{String, T}, placements::PlacementDict, map::Maple.Map, room::Room, name::String, x::Int, y::Int, nx::Int=x + 8, ny::Int=y + 8) where T
    target = getCachedPlacement!(cache, placements, name)
    ep = placements[name]

    return updateEntityPosition!(target, ep, map, room, x, y, nx, ny)
end

function propertyOptions(entity::Union{Maple.Entity, Maple.Trigger}, ignores::Array{String, 1}=String[])
    addedNodes = false
    res = Form.Option[]

    options = editingOptions(entity)
    horizontalAllowed, verticalAllowed = canResizeWrapper(entity)
    nodeRange = nodeLimits(entity)

    key = isa(entity, Maple.Entity) ? "entities" : "triggers"
    tooltips = get(langdata, ["placements", key, entity.name, "tooltips"])
    names = get(langdata, ["placements", key, entity.name, "names"])

    # Add nothing keys for all Dict editing options
    # Merge entity data over afterwards, this makes it possible to "store" nothing values for editing later
    data = merge(
        Dict{String, Any}(
            attr => nothing for (attr, value) in options if isa(value, Dict)
        ),
        entity.data
    )

    for (attr, value) in data
        if !horizontalAllowed && attr == "width" || !verticalAllowed && attr == "height"
            continue
        end

        # Always ignore these, regardless of ignore argument
        if attr == "originX" || attr == "originY"
            continue
        end

        # Special cased below
        if attr == "nodes"
            continue
        end

        if attr in ignores
            continue
        end

        if get(debug.config, "TOOLTIP_ENTITY_MISSING", false) && !haskey(tooltips, Symbol(attr))
            if !(attr in debug.defaultIgnoredTooltipAttrs)
                println("Missing tooltip for '$(entity.name)' - $attr")
            end
        end

        name = expandTooltipText(get(names, Symbol(attr), ""))
        displayName = isempty(name) ? humanizeVariableName(attr) : name
        tooltip = expandTooltipText(get(tooltips, Symbol(attr), ""))
        attrOptions = get(options, attr, nothing)

        push!(res, Form.suggestOption(displayName, value, dataName=attr, tooltip=tooltip, choices=attrOptions, editable=true))
    end

    if nodeRange[2] != 0 && !("nodes" in ignores)
        push!(res, Form.ListOption("Node X;Node Y", get(entity.data, "nodes", Tuple{Int, Int}[]), dataName="nodes", minRows=nodeRange[1], maxRows=nodeRange[2]))
    end

    return res
end

function selection(entity::Maple.Entity)
    return nothing
end

function selection(entity::Maple.Entity, room::Maple.Room)
    return nothing
end

function entitySelection(entity::Maple.Entity, room::Maple.Room, node::Int=0)
    return something(selection(entity), selection(entity, room), Rectangle(entity.x, entity.y, 4, 4))
end

const entityRng = MersenneTwister()

function getSimpleEntityRng(entity::Maple.Entity)::MersenneTwister
    x, y = position(entity)
    seed::Int = abs(x) << ceil(Int, log(2, abs(y) + 1)) | abs(y)

    return Random.seed!(entityRng, seed)
end

function getCachedPlacement!(cache::Dict{String, T}, placements::PlacementDict, name::String, map::Union{Maple.Map, Nothing}=Ahorn.loadedState.map, room::Union{Maple.Room, Nothing}=Ahorn.loadedState.room) where T <: Union{Entity, Trigger}
    if map !== nothing && room !== nothing
        if !haskey(cache, name)
            if haskey(placements, name)
                cache[name] = generateEntity(map, room, placements[name], 0, 0, 0, 0)
            end
        end
    end

    return get(cache, name, nothing)
end

function fillPlacementCache!(cache::Dict{String, T}, placements::PlacementDict, map::Union{Maple.Map, Nothing}=Ahorn.loadedState.map, room::Union{Maple.Room, Nothing}=Ahorn.loadedState.room) where T <: Union{Entity, Trigger}
    empty!(cache)

    for (name, placement) in placements
        getCachedPlacement!(cache, placements, name, map, room)
    end
end

const loadedEntities = joinpath.(abs"entities", readdir(abs"entities"))
const entityPlacements = PlacementDict()
const entityPlacementsCache = Dict{String, Entity}()