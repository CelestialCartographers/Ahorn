module Killbox

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Killbox" => Ahorn.EntityPlacement(
        Maple.Killbox,
        "rectangle"
    ),
)

Ahorn.minimumSize(entity::Maple.Killbox) = 8, 0
Ahorn.resizable(entity::Maple.Killbox) = true, false

function Ahorn.selection(entity::Maple.Killbox)
    x, y = Ahorn.position(entity)

    width = Int(get(entity.data, "width", 8))
    height = 32

    return Ahorn.Rectangle(x, y, width, height)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Killbox, room::Maple.Room)
    width = Int(get(entity.data, "width", 32))
    height = 32

    Ahorn.drawRectangle(ctx, 0, 0, width, height, (0.8, 0.4, 0.4, 0.8), (0.0, 0.0, 0.0, 0.0))
end

end