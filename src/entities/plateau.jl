module Plateau

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Plateau" => Ahorn.EntityPlacement(
        Maple.Plateau
    )
)

sprite = "scenery/fallplateau.png"

function Ahorn.selection(entity::Maple.Plateau)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.0, jy=0.0)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Plateau, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, 0, jx=0.0, jy=0.0)

end