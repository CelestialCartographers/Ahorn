function position(trigger::Maple.Trigger)
    return (
        floor(Int, trigger.x),
        floor(Int, trigger.y)
    )
end

function renderTrigger(ctx::Cairo.CairoContext, layer::Layer, trigger::Maple.Trigger, room::Maple.Room; alpha::Number=1)
    if ctx.ptr != C_NULL
        Cairo.save(ctx)

        x, y = Int(trigger.x), Int(trigger.y)
        width, height = Int(trigger.width), Int(trigger.height)

        rectangle(ctx, x, y, width, height)
        clip(ctx)

        text = humanizeVariableName(trigger.name)
        drawRectangle(ctx, x, y, width, height, colors.trigger_fc, colors.trigger_bc)
        drawCenteredText(ctx, text, x, y, width, height)

        restore(ctx)
    end
end

function renderTriggerSelection(ctx::Cairo.CairoContext, layer::Layer, trigger::Maple.Trigger, room::Maple.Room; alpha::Number=1)
    x, y = Int(trigger.data["x"]), Int(trigger.data["y"])
    width, height = Int(trigger.data["width"]), Int(trigger.data["height"])
    nodes = get(trigger.data, "nodes", Tuple{Integer, Integer}[])
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

minimumSize(trigger::Maple.Trigger) = 8, 8
resizable(trigger::Maple.Trigger) = true, true

function triggerSelection(trigger::Maple.Trigger, room::Maple.Room, node::Integer=0)
    x, y = Int(trigger.x), Int(trigger.y)
    width, height = Int(trigger.width), Int(trigger.height)
    nodes = get(trigger.data, "nodes", Tuple{Integer, Integer}[])

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
loadModule.(loadedTriggers)
const triggerPlacements = PlacementDict()
const triggerPlacementsCache = Dict{String, Trigger}()