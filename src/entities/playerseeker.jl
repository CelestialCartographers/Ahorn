module PlayerSeeker

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Player Seeker" => Ahorn.EntityPlacement(
        Maple.PlayerSeeker
    )
)

sprite = "decals/5-temple/statue_e.png"

function Ahorn.selection(entity::Maple.PlayerSeeker)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.PlayerSeeker, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, 0)

end