function renderTrigger(ctx::Cairo.CairoContext, layer::Layer, trigger::Maple.Trigger, room::Maple.Room; alpha::Number=1)
    Cairo.save(ctx)

    x, y = Int(trigger.data["x"]), Int(trigger.data["y"])
    width, height = Int(trigger.data["width"]), Int(trigger.data["height"])

    rectangle(ctx, x, y, width, height)
    clip(ctx)

    drawRectangle(ctx, x, y, width, height, colors.trigger_fc, colors.trigger_bc)
    centeredText(ctx, trigger.name, round(Int, x + width / 2), round(Int, y + height / 2))

    restore(ctx)
end

function minimumSize(trigger::Main.Maple.Trigger)
    if get(debug.config, "IGNORE_MINIMUM_SIZE", false)
        return 0, 0
    end
    
    return 8, 8
end

function canResize(trigger::Main.Maple.Trigger)
    return true, true
end

loadedTriggers = joinpath.("triggers", readdir(abs"triggers"))
append!(loadedTriggers, findExternalModules("triggers"))
loadModule.(loadedTriggers)

triggerPlacements = Dict{String, EntityPlacement}()
registerPlacements!(triggerPlacements, loadedTriggers)