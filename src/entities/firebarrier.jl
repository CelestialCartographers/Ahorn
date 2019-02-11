module FireBarrier

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Fire Barrier" => Ahorn.EntityPlacement(
        Maple.FireBarrier,
        "rectangle"
    ),
)

Ahorn.minimumSize(entity::Maple.FireBarrier) = 8, 8
Ahorn.resizable(entity::Maple.FireBarrier) = true, true

Ahorn.selection(entity::Maple.FireBarrier) = Ahorn.getEntityRectangle(entity)

edgeColor = (246, 98, 18, 255) ./ 255
centerColor = (209, 9, 1, 102) ./ 255

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.FireBarrier, room::Maple.Room)
    x = Int(get(entity.data, "x", 0))
    y = Int(get(entity.data, "y", 0))

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    Ahorn.drawRectangle(ctx, 0, 0, width, height, centerColor, edgeColor)
end

end