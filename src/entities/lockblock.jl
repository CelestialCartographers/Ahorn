module Lockblock

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
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

function Ahorn.selection(entity::Maple.LockBlock)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x, y, 32, 32)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.LockBlock, room::Maple.Room)
    sprite = get(entity.data, "sprite", "wood")

    if haskey(sprites, sprite)
        Ahorn.drawSprite(ctx, sprites[sprite], 16, 16)
    end
end

end