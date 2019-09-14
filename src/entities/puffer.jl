module Puffer

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Puffer (Right)" => Ahorn.EntityPlacement(
        Maple.Puffer,
        "point",
        Dict{String, Any}(
            "right" => true
        )
    ),
    "Puffer (Left)" => Ahorn.EntityPlacement(
        Maple.Puffer,
        "point",
        Dict{String, Any}(
            "right" => false
        )
    )    
)

sprite = "objects/puffer/idle00"

function Ahorn.selection(entity::Maple.Puffer)
    x, y = Ahorn.position(entity)
    scaleX = get(entity, "right", false) ? 1 : -1

    return Ahorn.getSpriteRectangle(sprite, x, y, sx=scaleX)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Puffer, room::Maple.Room)
    scaleX = get(entity, "right", false) ? 1 : -1

    Ahorn.drawSprite(ctx, sprite, 0, 0, sx=scaleX)
end

end