module TheoCrystal

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Theo Crystal" => Ahorn.EntityPlacement(
        Maple.TheoCrystal
    )
)

sprite = "characters/theoCrystal/idle00.png"

function Ahorn.selection(entity::Maple.TheoCrystal)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y - 10)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.TheoCrystal, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, -10)

end