module FireBarrier

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Fire Barrier" => Ahorn.EntityPlacement(
        Maple.FireBarrier,
        "rectangle"
    ),
)

function minimumSize(entity::Maple.Entity)
    if entity.name == "fireBarrier"
        return true, 8, 8
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "fireBarrier"
        return true, true, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "fireBarrier"
        x, y = Ahorn.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Ahorn.Rectangle(x, y, width, height)
    end
end

edgeColor = (246, 98, 18, 255) ./ 255
centerColor = (209, 9, 1, 102) ./ 255

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "fireBarrier"
        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        Ahorn.drawRectangle(ctx, 0, 0, width, height, centerColor, edgeColor)

        return true
    end

    return false
end

end