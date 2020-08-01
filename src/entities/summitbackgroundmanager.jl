module SummitBackgroundManager

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Summit Background Manager" => Ahorn.EntityPlacement(
        Maple.SummitBackgroundManager
    )
)

function Ahorn.selection(entity::Maple.SummitBackgroundManager)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle[Ahorn.Rectangle(x - 12, y - 12, 24, 24)]
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.SummitBackgroundManager, room::Maple.Room) = Ahorn.drawImage(ctx, Ahorn.Assets.summitBackgroundManager, -12, -12)

end