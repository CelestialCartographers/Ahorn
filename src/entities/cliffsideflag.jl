module CliffsideFlag

validFlagIndicdes = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "10"]

placements = Dict{String, Main.EntityPlacement}(
    "Cliffside Flag (Variant $(index))" => Main.EntityPlacement(
        Main.Maple.CliffsideFlag,
        "point",
        Dict{String, Any}(
            "index" => parse(Int, index),
        )
    ) for index in validFlagIndicdes
)

function editingOptions(entity::Main.Maple.Entity)
    if entity.name == "cliffside_flag"
        return true, Dict{String, Any}(
            "index" => ["00", "01", "02", "03", "04", "05", "06", "07", "08", "10"]
        )
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "cliffside_flag"
        x, y = Main.entityTranslation(entity)

        index = Int(get(entity.data, "index", 0))
        lookup = lpad(string(index), 2, "0")
        sprite = Main.sprites["scenery/cliffside/flag$(lookup)"]

        return true, Main.Rectangle(x, y, Int(sprite.width), Int(sprite.height))
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "cliffside_flag"
        index = Int(get(entity.data, "index", 0))
        lookup = lpad(string(index), 2, "0")
        Main.drawImage(ctx, "scenery/cliffside/flag$(lookup)", 0, 0)

        return true
    end

    return false
end

end