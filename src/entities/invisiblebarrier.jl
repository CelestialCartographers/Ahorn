module InvisibleBarrier

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Invisible Barrier" => Ahorn.EntityPlacement(
        Maple.Barrier,
        "rectangle"
    ),
)

Ahorn.minimumSize(entity::Maple.Barrier) = 8, 8
Ahorn.resizable(entity::Maple.Barrier) =  true, true

Ahorn.selection(entity::Maple.Barrier) = Ahorn.getEntityRectangle(entity)

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Barrier, room::Maple.Room)
    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    Ahorn.drawRectangle(ctx, 0, 0, width, height, (0.4, 0.4, 0.4, 0.8), (0.0, 0.0, 0.0, 0.0))
end

end