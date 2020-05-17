module Door

using ..Ahorn, Maple

const textures = ["wood", "metal"]
const placements = Ahorn.PlacementDict(
    "Door ($(uppercasefirst(texture)))" => Ahorn.EntityPlacement(
        Maple.Door,
        "point",
        Dict{String, Any}(
            "type" => texture
        )
    ) for texture in textures
)

function doorSprite(entity::Maple.Door)
    variant = get(entity.data, "type", "wood")

    return variant == "wood" ? "objects/door/door00.png" : "objects/door/metaldoor00.png"
end

Ahorn.editingOptions(entity::Maple.Door) = Dict{String, Any}(
    "type" => textures
)

function Ahorn.selection(entity::Maple.Door)
    x, y = Ahorn.position(entity)
    sprite = doorSprite(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.5, jy=1.0)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Door, room::Maple.Room)
    sprite = doorSprite(entity)
    Ahorn.drawSprite(ctx, sprite, 0, 0, jx=0.5, jy=1.0)
end

end