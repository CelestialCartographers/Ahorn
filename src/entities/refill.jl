module Refill

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Refill" => Ahorn.EntityPlacement(
        Maple.Refill
    )
)

function selection(entity::Maple.Entity)
    if entity.name == "refill"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 6, y - 6, 12, 12)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "refill"
        Ahorn.drawSprite(ctx, "objects/refill/idle00.png", 0, 0)

        return true
    end

    return false
end

end