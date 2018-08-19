module Checkpoint

using ..Ahorn, Maple

function selection(entity::Maple.Entity)
    if entity.name == "checkpoint"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 11, y - 24, 18, 24)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "checkpoint"
        Ahorn.drawSprite(ctx, "objects/checkpoint/flag16.png", 0, -16)

        return true
    end

    return false
end

end