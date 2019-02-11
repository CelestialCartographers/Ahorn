module Slider

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Slider (Clockwise)" => Ahorn.EntityPlacement(
        Maple.Slider,
        "point",
        Dict{String, Any}(
            "clockwise" => true
        )
    )
)

Ahorn.editingOptions(entity::Maple.Slider) =  Dict{String, Any}(
    "surface" => Maple.slider_surfaces
)

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Slider, room::Maple.Room)
    clockwise = get(entity.data, "clockwise", false)
    dir = clockwise ? 1 : -1

    x, y = Int(entity.data["x"]), Int(entity.data["y"])
    radius = 12

    Ahorn.drawArrow(ctx, x + radius, y, x + radius, y + 0.001 * dir, Ahorn.colors.selection_selected_fc, headLength=6)
    Ahorn.drawArrow(ctx, x - radius, y, x - radius, y + 0.001 * -dir, Ahorn.colors.selection_selected_fc, headLength=6)
end

function Ahorn.selection(entity::Maple.Slider)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - 12, y - 12, 24, 24)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Slider, room::Maple.Room) = Ahorn.drawCircle(ctx, 0, 0, 12, (1.0, 0.0, 0.0, 1.0))

end