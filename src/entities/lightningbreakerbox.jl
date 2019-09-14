module LightningBreakerBox

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Lightning Breaker Box" => Ahorn.EntityPlacement(
        Maple.LightningBreakerBox
    )
)

sprite = "objects/breakerBox/Idle00"

function Ahorn.selection(entity::Maple.LightningBreakerBox)
    x, y = Ahorn.position(entity)
    scaleX = get(entity, "flipX", false) ? -1 : 1

    return Ahorn.getSpriteRectangle(sprite, x, y, sx=scaleX)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.LightningBreakerBox, room::Maple.Room)
    scaleX = get(entity, "flipX", false) ? -1 : 1

    Ahorn.drawSprite(ctx, sprite, 0, 0, sx=scaleX)
end

end