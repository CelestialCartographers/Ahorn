module IceBlock

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Ice Block" => Ahorn.EntityPlacement(
        Maple.IceBlock,
        "rectangle"
    ),
)

Ahorn.minimumSize(entity::Maple.IceBlock) = 8, 8
Ahorn.resizable(entity::Maple.IceBlock) = true, true

Ahorn.selection(entity::Maple.IceBlock) = Ahorn.getEntityRectangle(entity)

edgeColor = (108, 214, 235, 255) ./ 255
centerColor = (76, 168, 214, 102) ./ 255

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.IceBlock, room::Maple.Room)
    x = Int(get(entity.data, "x", 0))
    y = Int(get(entity.data, "y", 0))

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    Ahorn.drawRectangle(ctx, 0, 0, width, height, centerColor, edgeColor)
end

end