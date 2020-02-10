module SandwichLava

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Sandwich Lava" => Ahorn.EntityPlacement(
        Maple.SandwichLava
    )
)

function Ahorn.selection(entity::Maple.SandwichLava)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - 12, y - 12, 24, 24)
end

edgeColor = (246, 98, 18, 255) ./ 255
centerColor = (209, 9, 1, 102) ./ 255

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.SandwichLava, room::Maple.Room) = Ahorn.drawImage(ctx, Ahorn.Assets.lavaSandwich, -12, -12)

end