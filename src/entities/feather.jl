module Feather

placements = Dict{String, Main.EntityPlacement}(
    "Feather" => Main.EntityPlacement(
        Main.Maple.Feather
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
        Main.drawSprite(ctx, "objects/flyFeather/idle00.png", 0, 0)

        return true
    end

    return false
end

end