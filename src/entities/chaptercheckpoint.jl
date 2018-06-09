module Checkpoint

function selection(entity::Main.Maple.Entity)
    if entity.name == "checkpoint"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 8, y - 8, 16, 16)
    end
end

# TODO - Render as tinted player entity when we have tinting
function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "checkpoint"
        Main.drawCircle(ctx, 0, 0, 8, (0.8, 0.4, 1.0, 0.8))

        return true
    end

    return false
end

end