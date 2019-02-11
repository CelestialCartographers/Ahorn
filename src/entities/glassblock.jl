module GlassBlock

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Glass Block" => Ahorn.EntityPlacement(
        Maple.GlassBlock,
        "rectangle"
    ),
)

Ahorn.minimumSize(entity::Maple.GlassBlock) = 8, 8
Ahorn.resizable(entity::Maple.GlassBlock) = true, true

Ahorn.selection(entity::Maple.GlassBlock) = Ahorn.getEntityRectangle(entity)

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.GlassBlock, room::Maple.Room)
    x = Int(get(entity.data, "x", 0))
    y = Int(get(entity.data, "y", 0))

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    Ahorn.drawRectangle(ctx, 0, 0, width, height, (1.0, 1.0, 1.0, 0.5), (1.0, 1.0, 1.0, 0.5))
end

end