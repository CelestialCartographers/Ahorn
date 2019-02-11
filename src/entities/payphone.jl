module Payphone

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Payphone" => Ahorn.EntityPlacement(
        Maple.Payphone
    )
)

sprite = "scenery/payphone.png"

function Ahorn.selection(entity::Maple.Payphone)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.5, jy=1.0)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Payphone, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, -32)

end