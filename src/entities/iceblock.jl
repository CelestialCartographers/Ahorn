module IceBlock

placements = Dict{String, Main.EntityPlacement}(
    "Ice Block" => Main.EntityPlacement(
        Main.Maple.IceBlock,
        "rectangle"
    ),
)

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "iceBlock"
        return true, 8, 8
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "iceBlock"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "iceBlock"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Main.Rectangle(x, y, width, height)
    end
end

edgeColor = (108, 214, 235, 255) ./ 255
centerColor = (76, 168, 214, 102) ./ 255

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "iceBlock"
        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        Main.drawRectangle(ctx, 0, 0, width, height, centerColor, edgeColor)

        return true
    end

    return false
end

end