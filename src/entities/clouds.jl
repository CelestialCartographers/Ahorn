module Clouds

placements = Dict{String, Main.EntityPlacement}(
    "Cloud (Normal)" => Main.EntityPlacement(
        Main.Maple.Cloud,
    ),
    "Cloud (Fragile)" => Main.EntityPlacement(
        Main.Maple.FragileCloud,
    )
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "cloud"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 16, y - 6, 32, 16)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "cloud"
        fragile = get(entity.data, "fragile", false)

        if fragile
            Main.drawSprite(ctx, "objects/clouds/fragile00.png", 0, 0)

        else
            Main.drawSprite(ctx, "objects/clouds/cloud00.png", 0, 0)
        end

        return true
    end

    return false
end

end