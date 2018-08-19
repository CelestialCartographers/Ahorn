module Torch

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
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

function selection(entity::Maple.Entity)
    if entity.name == "torch"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 6, y - 6, 12, 12)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "torch"
        lit = get(entity.data, "startLit", false)

        if lit
            Ahorn.drawSprite(ctx, "objects/temple/litTorch03.png", 0, 0)

        else
            Ahorn.drawSprite(ctx, "objects/temple/torch00.png", 0, 0)
        end

        return true
    end

    return false
end

end