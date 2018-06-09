module Blockfield

placements = Dict{String, Main.EntityPlacement}(
    "Strawberry Blockfield" => Main.EntityPlacement(
        Main.Maple.StrawberryBlockField,
        "rectangle"
    ),
)

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "blockField"
        return true, 8, 8
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "blockField"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "blockField"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Main.Rectangle(x, y, width, height)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "blockField"
        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        Main.drawRectangle(ctx, 0, 0, width, height, (0.4, 0.4, 1.0, 0.4), (0.4, 0.4, 1.0, 1.0))

        return true
    end

    return false
end

end