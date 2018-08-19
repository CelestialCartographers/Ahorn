module Door

using ..Ahorn, Maple

textures = ["wood", "metal"]
placements = Dict{String, Ahorn.EntityPlacement}(
    "Door ($(titlecase(texture)))" => Ahorn.EntityPlacement(
        Maple.Door,
        "point",
        Dict{String, Any}(
            "type" => texture
        )
    ) for texture in textures
)

function editingOptions(entity::Maple.Entity)
    if entity.name == "door"
        return true, Dict{String, Any}(
            "type" => textures
        )
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "door"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 2, y - 24, 4, 24)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "door"
        variant = get(entity.data, "type", "wood")

        if variant == "wood"
            Ahorn.drawSprite(ctx, "objects/door/door00.png", 0, -12)

        else
            Ahorn.drawSprite(ctx, "objects/door/metaldoor00.png", 0, -12)
        end

        return true
    end

    return false
end

end