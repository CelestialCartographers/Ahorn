module Cassette

placements = Dict{String, Main.EntityPlacement}(
    "Cassette" => Main.EntityPlacement(
        Main.Maple.Cassette
    ),
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "cassette"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 12, y - 8, 24, 16)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "cassette"
        Main.drawSprite(ctx, "collectables/cassette/idle00.png", 0, 0)

        return true
    end

    return false
end

end