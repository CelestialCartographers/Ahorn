module Clouds

placements = Dict{String, Main.EntityPlacement}(
    "Cloud (Normal)" => Main.EntityPlacement(
        Main.Maple.Cloud,
        "point",
        Dict{String, Any}(
            "fragile" => false,
            "small" => false
        )
    ),
    "Cloud (Fragile)" => Main.EntityPlacement(
        Main.Maple.Cloud,
        "point",
        Dict{String, Any}(
            "fragile" => true,
            "small" => false
        )
    ),
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "cloud"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 16, y - 6, 32, 16)
    end
end

normalScale = 1.0
smallScale = 29 / 35

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "cloud"
        fragile = get(entity.data, "fragile", false)
        small = get(entity.data, "small", false)

        if fragile
            Main.drawSprite(ctx, "objects/clouds/fragile00.png", 0, 0, sx=small? smallScale : normalScale)

        else
            Main.drawSprite(ctx, "objects/clouds/cloud00.png", 0, 0, sx=small? smallScale : normalScale)
        end

        return true
    end

    return false
end

end