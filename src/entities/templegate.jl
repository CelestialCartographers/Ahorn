module TempleGate

placements = Dict{String, Main.EntityPlacement}()

textures = ["default", "mirror", "theo"]
modes = ["NearestSwitch", "HoldingTheo", "TouchSwitches", "CloseBehindPlayer"]

for texture in textures
    for mode in modes
        key = "Temple Gate ($(titlecase(texture)), $mode)"
        placements[key] = Main.EntityPlacement(
            Main.Maple.TempleGate,
            "point",
            Dict{String, Any}(
                "sprite" => texture,
                "type" => mode
            )
        )
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "templeGate"
        x, y = Main.entityTranslation(entity)

        height = Int(get(entity.data, "height", 8))

        return true, Main.Rectangle(x - 4, y, 15, height)
    end
end

iconSprite = Main.sprites["objects/switchgate/icon00"]
sprites = Dict{String, String}(
    "default" => "objects/door/TempleDoor00",
    "mirror" => "objects/door/TempleDoorB00",
    "theo" => "objects/door/TempleDoorC00"
)

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "templeGate"
        sprite = get(entity.data, "sprite", "default")

        if haskey(sprites, sprite)
            Main.drawImage(ctx, sprites[sprite], -4, 0)
        end
        
        return true
    end
end

end