module Water

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Water" => Ahorn.EntityPlacement(
        Maple.Water,
        "rectangle"
    ),
)

Ahorn.minimumSize(entity::Maple.Water) = 8, 8
Ahorn.resizable(entity::Maple.Water) = true, true

Ahorn.selection(entity::Maple.Water) = Ahorn.getEntityRectangle(entity)

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Water, room::Maple.Room)
    x = Int(get(entity.data, "x", 0))
    y = Int(get(entity.data, "y", 0))

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    Ahorn.drawRectangle(ctx, 0, 0, width, height, (0.0, 0.0, 1.0, 0.4), (0.0, 0.0, 1.0, 1.0))
end

end