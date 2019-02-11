module OshiroBoss

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Oshiro Boss" => Ahorn.EntityPlacement(
        Maple.FriendlyGhost
    )
)

sprite = "characters/oshiro/boss13.png"

function Ahorn.selection(entity::Maple.FriendlyGhost)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.FriendlyGhost, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, 0)

end