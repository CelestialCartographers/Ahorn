module Lockblock

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Locked Door (Wood)" => Ahorn.EntityPlacement(
        Maple.LockBlock,
        "point",
        Dict{String, Any}(
            "sprite" => "wood"
        )
    ),
    "Locked Door (Temple A)" => Ahorn.EntityPlacement(
        Maple.LockBlock,
        "point",
        Dict{String, Any}(
            "sprite" => "temple_a"
        )
    ),
    "Locked Door (Temple B)" => Ahorn.EntityPlacement(
        Maple.LockBlock,
        "point",
        Dict{String, Any}(
            "sprite" => "temple_b"
        )
    )
)

sprites = Dict{String, String}(
    "wood" => "objects/door/lockdoor00.png",
    "temple_a" => "objects/door/lockdoorTempleA00.png",
    "temple_b" => "objects/door/lockdoorTempleB00.png",
)

function selection(entity::Maple.Entity)
    if entity.name == "lockBlock"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x, y, 32, 32)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "lockBlock"
        sprite = get(entity.data, "sprite", "wood")

        if haskey(sprites, sprite)
            Ahorn.drawSprite(ctx, sprites[sprite], 16, 16)
        end

        return true
    end

    return false
end

end