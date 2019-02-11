module Blockfield

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Strawberry Blockfield" => Ahorn.EntityPlacement(
        Maple.StrawberryBlockField,
        "rectangle"
    ),
)

Ahorn.minimumSize(entity::Maple.StrawberryBlockField) = 8, 8
Ahorn.resizable(entity::Maple.StrawberryBlockField) = true, true

Ahorn.selection(entity::Maple.StrawberryBlockField) = Ahorn.getEntityRectangle(entity)

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.StrawberryBlockField, room::Maple.Room)
    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    Ahorn.drawRectangle(ctx, 0, 0, width, height, (0.4, 0.4, 1.0, 0.4), (0.4, 0.4, 1.0, 1.0))
end

end