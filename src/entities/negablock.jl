module NegaBlock

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Nega Block" => Ahorn.EntityPlacement(
        Maple.NegaBlock,
        "rectangle"
    ),
)

Ahorn.minimumSize(entity::Maple.NegaBlock) = 8, 8
Ahorn.resizable(entity::Maple.NegaBlock) = true, true

Ahorn.selection(entity::Maple.NegaBlock) = Ahorn.getEntityRectangle(entity)

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.NegaBlock, room::Maple.Room)
    x = Int(get(entity.data, "x", 0))
    y = Int(get(entity.data, "y", 0))

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    Ahorn.drawRectangle(ctx, 0, 0, width, height, (1.0, 0.0, 0.0, 1.0), (0.0, 0.0, 0.0, 0.0))
end

end