module CliffsideFlag

using ..Ahorn, Maple

validFlagIndicdes = [0, 1, 2, 3, 4, 5, 6, 7, 9, 10]

placements = Dict{String, Ahorn.EntityPlacement}(
    "Cliffside Flag" => Ahorn.EntityPlacement(
        Maple.CliffsideFlag,
        "point"
    )
)

function editingOptions(entity::Maple.Entity)
    if entity.name == "cliffside_flag"
        return true, Dict{String, Any}(
            "index" => validFlagIndicdes
        )
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "cliffside_flag"
        x, y = Ahorn.entityTranslation(entity)

        index = Int(get(entity.data, "index", 0))
        lookup = lpad(string(index), 2, "0")
        sprite = Ahorn.sprites["scenery/cliffside/flag$(lookup)"]

        return true, Ahorn.Rectangle(x, y, Int(sprite.width), Int(sprite.height))
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "cliffside_flag"
        index = Int(get(entity.data, "index", 0))
        lookup = lpad(string(index), 2, "0")
        Ahorn.drawImage(ctx, "scenery/cliffside/flag$(lookup)", 0, 0)

        return true
    end

    return false
end

end