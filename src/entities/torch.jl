module Torch

placements = Dict{String, Main.EntityPlacement}(
    "Torch" => Main.EntityPlacement(
        Main.Maple.Torch,
        "point",
        Dict{String, Any}(
            "startLit" => false
        )
    ),
    "Torch (Lit)" => Main.EntityPlacement(
        Main.Maple.Torch,
        "point",
        Dict{String, Any}(
            "startLit" => true
        )
    ),
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "torch"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 6, y - 6, 12, 12)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "torch"
        lit = get(entity.data, "startLit", false)

        if lit
            Main.drawSprite(ctx, "objects/temple/litTorch03.png", 0, 0)

        else
            Main.drawSprite(ctx, "objects/temple/torch00.png", 0, 0)
        end

        return true
    end

    return false
end

end