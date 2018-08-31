module RisingLava

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Rising Lava" => Ahorn.EntityPlacement(
        Maple.RisingLava
    )
)

function selection(entity::Maple.Entity)
    if entity.name == "risingLava"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 12, y - 12, 24, 24)
    end
end

edgeColor = (246, 98, 18, 255) ./ 255
centerColor = (209, 9, 1, 102) ./ 255

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "risingLava"
        Ahorn.Cairo.save(ctx)

        Ahorn.set_antialias(ctx, 1)
        Ahorn.set_line_width(ctx, 1);

        Ahorn.drawCircle(ctx, 0, 0, 12, (1.0, 1.0, 1.0, 1.0))

        Ahorn.arc(ctx, 0, 0, 11, 0, 2 * pi)
        Ahorn.clip(ctx)

        Ahorn.drawRectangle(ctx, -12, 5, 24, 8, centerColor, edgeColor)

        Ahorn.Cairo.restore(ctx)

        return true
    end

    return false
end

end