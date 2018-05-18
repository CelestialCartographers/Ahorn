module Slider

placements = Dict{String, Main.EntityPlacement}(
    "Slider (Clockwise)" => Main.EntityPlacement(
        Main.Maple.Slider,
        "point",
        Dict{String, Any}(
            "clockwise" => true
        )
    ),
    "Slider" => Main.EntityPlacement(
        Main.Maple.Slider,
        "point",
        Dict{String, Any}(
            "clockwise" => false
        )
    ),
)

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "slider"
        clockwise = get(entity.data, "clockwise", false)
        dir = clockwise? 1 : -1

        x, y = Int(entity.data["x"]), Int(entity.data["y"])
        radius = 12

        Main.drawArrow(ctx, x + radius, y, x + radius, y + 0.001 * dir, Main.colors.selection_selected_fc, headLength=6)
        Main.drawArrow(ctx, x - radius, y, x - radius, y + 0.001 * -dir, Main.colors.selection_selected_fc, headLength=6)

        return true
    end

    return false
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "slider"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 12, y - 12, 24, 24)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "slider"
        Main.drawCircle(ctx, 0, 0, 12, (1.0, 0.0, 0.0, 1.0))

        return true
    end

    return false
end

end