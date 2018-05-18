module Player

placements = Dict{String, Main.EntityPlacement}(
    "Player" => Main.EntityPlacement(
        Main.Maple.Player
    )
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "player"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 2, y - 16, 12, 16)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity)
    if entity.name == "player"
        Main.drawSprite(ctx, "characters/player/sitDown00.png", 4, -16)

        return true
    end
end

end