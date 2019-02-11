module SeekerBarrier

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Seeker Barrier" => Ahorn.EntityPlacement(
        Maple.SeekerBarrier,
        "rectangle"
    ),
)

Ahorn.minimumSize(entity::Maple.SeekerBarrier) = 8, 8
Ahorn.resizable(entity::Maple.SeekerBarrier) = true, true

function Ahorn.selection(entity::Maple.SeekerBarrier)
    x, y = Ahorn.position(entity)

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))

    return Ahorn.Rectangle(x, y, width, height)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.SeekerBarrier, room::Maple.Room)
    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    Ahorn.drawRectangle(ctx, 0, 0, width, height, (0.25, 0.25, 0.25, 0.8), (0.0, 0.0, 0.0, 0.0))
end

end