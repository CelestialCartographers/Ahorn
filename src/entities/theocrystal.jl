module TheoCrystal

placements = Dict{String, Main.EntityPlacement}(
    "Theo Crystal" => Main.EntityPlacement(
        Main.Maple.TheoCrystal
    )
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "theoCrystal"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 10, y - 20, 20, 20)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "theoCrystal"
        Main.drawSprite(ctx, "characters/theoCrystal/idle00.png", 0, -10)

        return true
    end

    return false
end

end