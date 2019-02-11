module Player

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Player (Spawn Point)" => Ahorn.EntityPlacement(
        Maple.Player
    )
)

sprite = "characters/player/sitDown00.png"

function Ahorn.selection(entity::Maple.Player)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.5, jy=1.0)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Player) = Ahorn.drawSprite(ctx, sprite, 0, 0, jx=0.5, jy=1.0)

end