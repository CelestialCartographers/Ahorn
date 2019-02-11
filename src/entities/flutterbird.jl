module FlutterBird

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Flutterbird" => Ahorn.EntityPlacement(
        Maple.Flutterbird
    ),
)

sprite = "scenery/flutterbird/idle00.png"

colors = [
    (137, 251, 255, 255) ./ 255,
    (240, 252, 108, 255) ./ 255,
    (244, 147, 255, 255) ./ 255,
    (147, 186, 255, 255) ./ 255
]

function Ahorn.selection(entity::Maple.Flutterbird)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.5, jy=1.0)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Flutterbird, room::Maple.Room)
    rng = Ahorn.getSimpleEntityRng(entity)
    color = rand(rng, colors)

    Ahorn.drawSprite(ctx, sprite, 0, 0, jx=0.5, jy=1.0, tint=color)
end

end