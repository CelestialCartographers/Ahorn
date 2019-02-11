module Trapdoor

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Trapdoor" => Ahorn.EntityPlacement(
        Maple.Trapdoor
    )
)

# Doesn't seem to have a sprite?
doorColor = (22, 27, 48, 1) ./ (255, 255, 255, 1)

function Ahorn.selection(entity::Maple.Trapdoor)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x, y + 5, 24, 4)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Trapdoor, room::Maple.Room) = Ahorn.drawRectangle(ctx, 0, 6, 24, 2, doorColor)

end