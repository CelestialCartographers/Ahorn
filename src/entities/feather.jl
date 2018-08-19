module Feather

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Feather" => Ahorn.EntityPlacement(
        Maple.Feather
    ),
    "Feather (Shielded)" => Ahorn.EntityPlacement(
        Maple.Feather,
        "point",
        Dict{String, Any}(
            "shielded" => true
        )
    )
)

function selection(entity::Maple.Entity)
    if entity.name == "infiniteStar"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 8, y - 8, 16, 16)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "infiniteStar"
        if get(entity.data, "shielded", false)
            Ahorn.Cairo.save(ctx)

            Ahorn.set_antialias(ctx, 1)
            Ahorn.set_line_width(ctx, 1);

            Ahorn.drawCircle(ctx, 0, 0, 12, (1.0, 1.0, 1.0, 1.0))

            Ahorn.Cairo.restore(ctx)
        end

        Ahorn.drawSprite(ctx, "objects/flyFeather/idle00.png", 0, 0)

        return true
    end

    return false
end

end