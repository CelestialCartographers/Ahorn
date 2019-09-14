module Jellyfish

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Jellyfish" => Ahorn.EntityPlacement(
        Maple.Jellyfish
    ),
    "Jellyfish (Floating)" => Ahorn.EntityPlacement(
        Maple.Jellyfish,
        "point",
        Dict{String, Any}(
            "bubble" => true
        )
    )
)

sprite = "objects/glider/idle0"

function Ahorn.selection(entity::Maple.Jellyfish)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Jellyfish, room::Maple.Room)
    Ahorn.drawSprite(ctx, sprite, 0, 0)

    if get(entity, "bubble", false)
        curve = Ahorn.SimpleCurve((-7, -1), (7, -1), (0, -6))
        Ahorn.drawSimpleCurve(ctx, curve, (1.0, 1.0, 1.0, 1.0), thickness=1)
    end
end

end