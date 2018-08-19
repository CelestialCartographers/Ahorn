module Clouds

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
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

function selection(entity::Maple.Entity)
    if entity.name == "cloud"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 16, y - 6, 32, 16)
    end
end

normalScale = 1.0
smallScale = 29 / 35

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "cloud"
        fragile = get(entity.data, "fragile", false)
        small = get(entity.data, "small", false)

        if fragile
            Ahorn.drawSprite(ctx, "objects/clouds/fragile00.png", 0, 0, sx=small? smallScale : normalScale)

        else
            Ahorn.drawSprite(ctx, "objects/clouds/cloud00.png", 0, 0, sx=small? smallScale : normalScale)
        end

        return true
    end

    return false
end

end