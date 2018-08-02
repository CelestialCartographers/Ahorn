function renderTrigger(ctx::Cairo.CairoContext, layer::Layer, trigger::Maple.Trigger, room::Maple.Room; alpha::Number=1)
    Cairo.save(ctx)

    x, y = Int(trigger.data["x"]), Int(trigger.data["y"])
    width, height = Int(trigger.data["width"]), Int(trigger.data["height"])

    rectangle(ctx, x, y, width, height)
    clip(ctx)

    text = humanizeVariableName(trigger.name)
    drawRectangle(ctx, x, y, width, height, colors.trigger_fc, colors.trigger_bc)
    centeredText(ctx, text, round(Int, x + width / 2), round(Int, y + height / 2))

    restore(ctx)
end

function renderTriggerSelection(ctx::Cairo.CairoContext, layer::Layer, trigger::Maple.Trigger, room::Maple.Room; alpha::Number=1)
    x, y = Int(trigger.data["x"]), Int(trigger.data["y"])
    width, height = Int(trigger.data["width"]), Int(trigger.data["height"])
    nodes = get(trigger.data, "nodes", Tuple{Integer, Integer}[])
    offsetCenterX, offsetCenterY = floor(Int, width / 2), floor(Int, height / 2)
    
    text = humanizeVariableName(trigger.name)

    for node in nodes
        nx, ny = Int.(node)

        Main.drawArrow(ctx, x + offsetCenterX, y + offsetCenterY, nx + offsetCenterX, ny + offsetCenterY, Main.colors.selection_selected_fc, headLength=6)

        Cairo.save(ctx)

        rectangle(ctx, nx, ny, width, height)
        clip(ctx)
    
        drawRectangle(ctx, nx, ny, width, height, colors.trigger_fc, colors.trigger_bc)
        centeredText(ctx, text, round(Int, nx + width / 2), round(Int, ny + height / 2))

        Cairo.restore(ctx)
    end
end

function minimumSize(trigger::Main.Maple.Trigger)
    if get(debug.config, "IGNORE_MINIMUM_SIZE", false)
        return 0, 0
    end
    
    return 8, 8
end

function nodeLimits(trigger::Main.Maple.Trigger)
    selectionRes = Main.eventToModules(Main.loadedTriggers, "nodeLimits", trigger)
    
    if isa(selectionRes, Tuple)
        success, least, most = selectionRes

        if success
            return least, most
        end
    end

    return 0, 0
end

function editingOptions(trigger::Maple.Trigger)
    selectionRes = Main.eventToModules(Main.loadedTriggers, "editingOptions", trigger)
    
    if isa(selectionRes, Tuple)
        success, options = selectionRes

        if success
            return success, options
        end
    end

    return false, Dict{String, Any}()
end

function canResize(trigger::Main.Maple.Trigger)
    return true, true
end

loadedTriggers = joinpath.("triggers", readdir(abs"triggers"))
append!(loadedTriggers, findExternalModules("triggers"))
loadModule.(loadedTriggers)
loadExternalModules!(loadedModules, loadedTriggers, "triggers")

triggerPlacements = Dict{String, EntityPlacement}()
registerPlacements!(triggerPlacements, loadedTriggers)