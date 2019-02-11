module OshiroDoor

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Oshiro Door" => Ahorn.EntityPlacement(
        Maple.OshiroDoor
    )
)

clutterDoorColor = (74, 71, 135, 153) ./ 255.0

function Ahorn.selection(entity::Maple.OshiroDoor)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - 16, y - 16, 32, 32)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.OshiroDoor, room::Maple.Room)
    Ahorn.drawSprite(ctx, "characters/oshiro/oshiro24", 0, 0, alpha=0.8)
    Ahorn.drawRectangle(ctx, -16, -16, 32, 32, clutterDoorColor, (1.0, 1.0, 1.0, 8.0))
end

end