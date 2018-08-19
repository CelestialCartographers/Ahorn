module Slider

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Slider (Clockwise)" => Ahorn.EntityPlacement(
        Maple.Slider,
        "point",
        Dict{String, Any}(
            "clockwise" => true
        )
    )
)

function editingOptions(entity::Maple.Entity)
    if entity.name == "slider"
        return true, Dict{String, Any}(
            "surface" => Maple.slider_surfaces
        )
    end
end

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "slider"
        clockwise = get(entity.data, "clockwise", false)
        dir = clockwise? 1 : -1

        x, y = Int(entity.data["x"]), Int(entity.data["y"])
        radius = 12

        Ahorn.drawArrow(ctx, x + radius, y, x + radius, y + 0.001 * dir, Ahorn.colors.selection_selected_fc, headLength=6)
        Ahorn.drawArrow(ctx, x - radius, y, x - radius, y + 0.001 * -dir, Ahorn.colors.selection_selected_fc, headLength=6)

        return true
    end

    return false
end

function selection(entity::Maple.Entity)
    if entity.name == "slider"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 12, y - 12, 24, 24)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "slider"
        Ahorn.drawCircle(ctx, 0, 0, 12, (1.0, 0.0, 0.0, 1.0))

        return true
    end

    return false
end

end