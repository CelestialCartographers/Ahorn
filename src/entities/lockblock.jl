module Lockblock

placements = Dict{String, Main.EntityPlacement}(
    "Locked Door (Wood)" => Main.EntityPlacement(
        Main.Maple.LockBlock,
        "point",
        Dict{String, Any}(
            "sprite" => "wood"
        )
    ),
    "Locked Door (Temple A)" => Main.EntityPlacement(
        Main.Maple.LockBlock,
        "point",
        Dict{String, Any}(
            "sprite" => "temple_a"
        )
    ),
    "Locked Door (Temple B)" => Main.EntityPlacement(
        Main.Maple.LockBlock,
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

function selection(entity::Main.Maple.Entity)
    if entity.name == "lockBlock"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x, y, 32, 32)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "lockBlock"
        sprite = get(entity.data, "sprite", "wood")

        if haskey(sprites, sprite)
            Main.drawSprite(ctx, sprites[sprite], 16, 16)
        end

        return true
    end

    return false
end

end