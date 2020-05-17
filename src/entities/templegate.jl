module TempleGate

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
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
    "Temple Gate (Mirror, Close Behind)" => Ahorn.EntityPlacement(
        Maple.TempleGate,
        "point",
        Dict{String, Any}(
            "sprite" => "mirror",
            "type" => "CloseBehindPlayer",
        )
    ),

    "Temple Gate (Default, Nearest Switch)" => Ahorn.EntityPlacement(
        Maple.TempleGate,
        "point",
        Dict{String, Any}(
            "sprite" => "default",
            "type" => "NearestSwitch",
        )
    ),
    "Temple Gate (Mirror, Nearest Switch)" => Ahorn.EntityPlacement(
        Maple.TempleGate,
        "point",
        Dict{String, Any}(
            "sprite" => "mirror",
            "type" => "NearestSwitch",
        )
    ),


    "Temple Gate (Default, Touch Switches)" => Ahorn.EntityPlacement(
        Maple.TempleGate,
        "point",
        Dict{String, Any}(
            "sprite" => "default",
            "type" => "TouchSwitches",
        )
    ),
    "Temple Gate (Mirror, Touch Switches)" => Ahorn.EntityPlacement(
        Maple.TempleGate,
        "point",
        Dict{String, Any}(
            "sprite" => "mirror",
            "type" => "TouchSwitches",
        )
    ),
)

const textures = String["default", "mirror", "theo"]
const modes = Maple.temple_gate_modes

Ahorn.editingOptions(entity::Maple.TempleGate) = Dict{String, Any}(
    "type" => modes,
    "sprite" => textures
)

function Ahorn.selection(entity::Maple.TempleGate)
    x, y = Ahorn.position(entity)
    height = Int(get(entity.data, "height", 8))

    return Ahorn.Rectangle(x - 4, y, 15, height)
end

const sprites = Dict{String, String}(
    "default" => "objects/door/TempleDoor00",
    "mirror" => "objects/door/TempleDoorB00",
    "theo" => "objects/door/TempleDoorC00"
)

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.TempleGate, room::Maple.Room)
    sprite = get(entity.data, "sprite", "default")

    if haskey(sprites, sprite)
        Ahorn.drawImage(ctx, sprites[sprite], -4, 0)
    end
end

end