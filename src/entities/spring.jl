module Spring

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Spring (Up)" => Ahorn.EntityPlacement(
        Maple.Spring
    ),
    "Spring (Left)" => Ahorn.EntityPlacement(
        Maple.SpringRight
    ),
    "Spring (Right)" => Ahorn.EntityPlacement(
        Maple.SpringLeft
    ),
)

function Ahorn.selection(entity::Maple.Spring)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - 6, y - 3, 12, 5)
end

function Ahorn.selection(entity::Maple.SpringLeft)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - 1, y - 6, 5, 12)
end

function Ahorn.selection(entity::Maple.SpringRight)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - 4, y - 6, 5, 12)
end

sprite = "objects/spring/00.png"

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Spring, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, -8)
Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.SpringLeft, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 9, -11, rot=pi / 2)
Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.SpringRight, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 3, 1, rot=-pi / 2)

end