module RisingLava

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Rising Lava" => Ahorn.EntityPlacement(
        Maple.RisingLava
    )
)

function Ahorn.selection(entity::Maple.RisingLava)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - 12, y - 12, 24, 24)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.RisingLava, room::Maple.Room) = Ahorn.drawImage(ctx, Ahorn.Assets.risingLava, -12, -12)

end