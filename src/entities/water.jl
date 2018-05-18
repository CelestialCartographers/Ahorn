module Water

placements = Dict{String, Main.EntityPlacement}(
    "Water" => Main.EntityPlacement(
        Main.Maple.Water,
        "rectangle"
    ),
)

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "water"
        return true, 8, 8
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "water"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "water"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Main.Rectangle(x, y, width, height)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "water"
        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        Main.drawRectangle(ctx, 0, 0, width, height, (0.0, 0.0, 1.0, 0.4), (0.0, 0.0, 1.0, 1.0))

        return true
    end

    return false
end

end