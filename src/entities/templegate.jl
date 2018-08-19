module TempleGate

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Temple Gate (Theo, Holding Theo)" => Ahorn.EntityPlacement(
        Maple.TempleGate,
        "point",
        Dict{String, Any}(
            "sprite" => "theo",
            "type" => "HoldingTheo"
        )
    ),

    "Temple Gate (Default, Close Behind)" => Ahorn.EntityPlacement(
        Maple.TempleGate,
        "point",
        Dict{String, Any}(
            "sprite" => "default",
            "type" => "CloseBehindPlayer",
        )
    ),
    "Temple Gate (Default, Close Behind)" => Ahorn.EntityPlacement(
        Maple.TempleGate,
        "point",
        Dict{String, Any}(
            "sprite" => "mirror",
            "type" => "CloseBehindPlayer",
        )
    ),
)

textures = ["default", "mirror", "theo"]
modes = Maple.temple_gate_modes

# One per texture of NearestSwitch
for texture in textures
    key = "Temple Gate ($(titlecase(texture)), Nearest Switch)"
    placements[key] = Ahorn.EntityPlacement(
        Maple.TempleGate,
        "point",
        Dict{String, Any}(
            "sprite" => texture,
            "type" => "NearestSwitch"
        )
    )
end

function editingOptions(entity::Maple.Entity)
    if entity.name == "templeGate"
        return true, Dict{String, Any}(
            "type" => modes,
            "sprite" => textures
        )
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "templeGate"
        x, y = Ahorn.entityTranslation(entity)

        height = Int(get(entity.data, "height", 8))

        return true, Ahorn.Rectangle(x - 4, y, 15, height)
    end
end

sprites = Dict{String, String}(
    "default" => "objects/door/TempleDoor00",
    "mirror" => "objects/door/TempleDoorB00",
    "theo" => "objects/door/TempleDoorC00"
)

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "templeGate"
        sprite = get(entity.data, "sprite", "default")

        if haskey(sprites, sprite)
            Ahorn.drawImage(ctx, sprites[sprite], -4, 0)
        end
        
        return true
    end
end

end