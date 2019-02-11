module FloatingDebris

using ..Ahorn, Maple
using Random

const placements = Ahorn.PlacementDict(
    "Floating Debris" => Ahorn.EntityPlacement(
        Maple.FloatingDebris
    )
)

function Ahorn.selection(entity::Maple.FloatingDebris)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - 6, y - 6, 12, 12)
end

debrisName = "scenery/debris"

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.FloatingDebris, room::Maple.Room)
    rng = Ahorn.getSimpleEntityRng(entity)
    debrisSprite = Ahorn.getSprite(debrisName, "Gameplay")

    offset = rand(rng, 0:7)

    Ahorn.drawImage(ctx, debrisSprite, -4, -4, offset * 8, 0, 8, 8)
end

end