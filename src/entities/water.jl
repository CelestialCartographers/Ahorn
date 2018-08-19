module Water

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Water" => Ahorn.EntityPlacement(
        Maple.Water,
        "rectangle"
    ),
)

function minimumSize(entity::Maple.Entity)
    if entity.name == "water"
        return true, 8, 8
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "water"
        return true, true, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "water"
        x, y = Ahorn.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Ahorn.Rectangle(x, y, width, height)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "water"
        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        Ahorn.drawRectangle(ctx, 0, 0, width, height, (0.0, 0.0, 1.0, 0.4), (0.0, 0.0, 1.0, 1.0))

        return true
    end

    return false
end

end