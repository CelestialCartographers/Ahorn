module Door

textures = ["wood", "metal"]
placements = Dict{String, Main.EntityPlacement}(
    "Door ($(titlecase(texture)))" => Main.EntityPlacement(
        Main.Maple.Door,
        "point",
        Dict{String, Any}(
            "type" => texture
        )
    ) for texture in textures
)

function editingOptions(entity::Main.Maple.Entity)
    if entity.name == "door"
        return true, Dict{String, Any}(
            "type" => textures
        )
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "door"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 2, y - 24, 4, 24)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "door"
        variant = get(entity.data, "type", "wood")

        if variant == "wood"
            Main.drawSprite(ctx, "objects/door/door00.png", 0, -12)

        else
            Main.drawSprite(ctx, "objects/door/metaldoor00.png", 0, -12)
        end

        return true
    end

    return false
end

end