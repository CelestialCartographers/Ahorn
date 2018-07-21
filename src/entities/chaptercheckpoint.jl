module Checkpoint

function selection(entity::Main.Maple.Entity)
    if entity.name == "checkpoint"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 11, y - 24, 18, 24)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "checkpoint"
        Main.drawSprite(ctx, "objects/checkpoint/flag16.png", 0, -16)

        return true
    end

    return false
end

end