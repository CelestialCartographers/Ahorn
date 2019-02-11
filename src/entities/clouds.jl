module Clouds

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Cloud (Normal)" => Ahorn.EntityPlacement(
        Maple.Cloud,
        "point",
        Dict{String, Any}(
            "fragile" => false,
            "small" => false
        )
    ),
    "Cloud (Fragile)" => Ahorn.EntityPlacement(
        Maple.Cloud,
        "point",
        Dict{String, Any}(
            "fragile" => true,
            "small" => false
        )
    ),
)

normalScale = 1.0
smallScale = 29 / 35

function cloudSprite(entity::Maple.Cloud)
    fragile = get(entity.data, "fragile", false)

    return fragile ? "objects/clouds/fragile00.png" : "objects/clouds/cloud00.png"
end

function cloudScale(entity::Maple.Cloud)
    small = get(entity.data, "small", false)

    return small ? smallScale : normalScale
end

function Ahorn.selection(entity::Maple.Cloud)
    x, y = Ahorn.position(entity)

    sprite = cloudSprite(entity)
    scaleX = cloudScale(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, sx=scaleX)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Cloud, room::Maple.Room)
    sprite = cloudSprite(entity)
    scaleX = cloudScale(entity)

    Ahorn.drawSprite(ctx, sprite, 0, 0, sx=scaleX)
end

end