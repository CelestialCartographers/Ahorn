module Refill

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Refill" => Ahorn.EntityPlacement(
        Maple.Refill
    ),

    "Refill (Two Dashes)" => Ahorn.EntityPlacement(
        Maple.Refill,
        "point",
        Dict{String, Any}(
            "twoDash" => true
        )
    )
)

spriteOneDash = "objects/refill/idle00"
spriteTwoDash = "objects/refillTwo/idle00"

function getSprite(entity::Maple.Refill)
    twoDash = get(entity.data, "twoDash", false)

    return twoDash ? spriteTwoDash : spriteOneDash
end

function Ahorn.selection(entity::Maple.Refill)
    x, y = Ahorn.position(entity)
    sprite = getSprite(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Refill, room::Maple.Room)
    sprite = getSprite(entity)
    Ahorn.drawSprite(ctx, sprite, 0, 0)
end

end