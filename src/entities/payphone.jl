module Payphone

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Payphone" => Ahorn.EntityPlacement(
        Maple.Payphone
    )
)

function selection(entity::Maple.Entity)
    if entity.name == "payphone"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 16, y - 54, 32, 54)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "payphone"
        Ahorn.drawSprite(ctx, "scenery/payphone.png", 0, -32)

        return true
    end

    return false
end

end