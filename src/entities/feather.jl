module Feather

placements = Dict{String, Main.EntityPlacement}(
    "Feather" => Main.EntityPlacement(
        Main.Maple.Feather
    ),
    "Feather (Shielded)" => Main.EntityPlacement(
        Main.Maple.Feather,
        "point",
        Dict{String, Any}(
            "shielded" => true
        )
    )
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "infiniteStar"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 8, y - 8, 16, 16)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "infiniteStar"
        if get(entity.data, "shielded", false)
            Main.Cairo.save(ctx)

            Main.set_antialias(ctx, 1)
            Main.set_line_width(ctx, 1);

            Main.drawCircle(ctx, 0, 0, 12, (1.0, 1.0, 1.0, 1.0))

            Main.Cairo.restore(ctx)
        end

        Main.drawSprite(ctx, "objects/flyFeather/idle00.png", 0, 0)

        return true
    end

    return false
end

end