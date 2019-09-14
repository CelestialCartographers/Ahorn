module MoonCreature

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Moon Creature" => Ahorn.EntityPlacement(
        Maple.MoonCreature
    )
)

sprite = "scenery/moon_creatures/tiny05"

function Ahorn.selection(entity::Maple.MoonCreature)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.MoonCreature, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, 0)

end