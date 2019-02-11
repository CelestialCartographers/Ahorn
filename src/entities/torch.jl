module Torch

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Torch" => Ahorn.EntityPlacement(
        Maple.Torch,
        "point",
        Dict{String, Any}(
            "startLit" => false
        )
    ),
    "Torch (Lit)" => Ahorn.EntityPlacement(
        Maple.Torch,
        "point",
        Dict{String, Any}(
            "startLit" => true
        )
    ),
)

function torchSprite(entity::Maple.Torch)
    lit = get(entity.data, "startLit", false)
    
    return lit ? "objects/temple/litTorch03.png" : "objects/temple/torch00.png"
end

function Ahorn.selection(entity::Maple.Torch)
    x, y = Ahorn.position(entity)
    sprite = torchSprite(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Torch, room::Maple.Room)
    sprite = torchSprite(entity)
    Ahorn.drawSprite(ctx, sprite, 0, 0)
end

end