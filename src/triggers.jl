function position(trigger::Maple.Trigger)::Tuple{Int, Int}
    return floor(Int, get(trigger, "x", 0)), floor(Int, get(trigger, "y", 0))
end

function renderTrigger(ctx::Cairo.CairoContext, layer::Layer, trigger::Maple.Trigger, room::Maple.Room; alpha=nothing)
    if ctx.ptr != C_NULL
        Cairo.save(ctx)

        x, y = position(trigger)
        w, h = Int(trigger.width), Int(trigger.height)

        rectangle(ctx, x, y, w, h)
        clip(ctx)

        text = humanizeVariableName(trigger.name)
        drawRectangle(ctx, x, y, w, h, colors.trigger_fc, colors.trigger_bc)
        drawCenteredText(ctx, text, x, y, w, h)

        restore(ctx)
    end
end

function renderTriggerSelection(ctx::Cairo.CairoContext, layer::Layer, trigger::Maple.Trigger, room::Maple.Room; alpha=nothing)
    x, y = Int(trigger.data["x"]), Int(trigger.data["y"])
    width, height = Int(trigger.data["width"]), Int(trigger.data["height"])
    nodes = get(trigger.data, "nodes", Tuple{Int, Int}[])
    offsetCenterX, offsetCenterY = floor(Int, width / 2), floor(Int, height / 2)

    text = humanizeVariableName(trigger.name)

    for node in nodes
        nx, ny = Int.(node)

        drawArrow(ctx, x + offsetCenterX, y + offsetCenterY, nx + 4, ny + 4, colors.selection_selected_fc, headLength=6)
        drawRectangle(ctx, nx, ny, 8, 8, colors.trigger_fc, colors.trigger_bc)
    end
end

nodeLimits(trigger::Maple.Trigger) = 0, 0

editingOptions(trigger::Maple.Trigger) = Dict{String, Any}()
editingOrder(trigger::Maple.Trigger) = String["x", "y", "width", "height"]
editingIgnored(trigger::Maple.Trigger, multiple::Bool=false) = multiple ? String["x", "y", "width", "height", "nodes"] : String[]

minimumSize(trigger::Maple.Trigger) = 8, 8
resizable(trigger::Maple.Trigger) = true, true

deleted(trigger::Maple.Trigger, node::Int) = nothing

moved(trigger::Maple.Trigger) = nothing
moved(trigger::Maple.Trigger, x::Int, y::Int) = nothing

resized(trigger::Maple.Trigger) = nothing
resized(trigger::Maple.Trigger, width::Int, height::Int) = nothing

flipped(trigger::Maple.Trigger, horizontal::Bool) = nothing

rotated(trigger::Maple.Trigger, steps::Int) = nothing

function triggerSelection(trigger::Maple.Trigger, room::Maple.Room, node::Int=0)
    x, y = Int(trigger.x), Int(trigger.y)
    width, height = Int(trigger.width), Int(trigger.height)
    nodes = get(trigger.data, "nodes", Tuple{Int, Int}[])

    if isempty(nodes)
        return Rectangle(x, y, width, height)

    else
        res = Rectangle[Rectangle(x, y, width, height)]

        for node in nodes
            nx, ny = Int.(node)

            push!(res, Rectangle(nx, ny, 8, 8))
        end

        return res
    end
end

const loadedTriggers = joinpath.(abs"triggers", readdir(abs"triggers"))
const triggerPlacements = PlacementDict()
const triggerPlacementsCache = Dict{String, Trigger}()