module Key

placements = Dict{String, Main.EntityPlacement}(
    "Key" => Main.EntityPlacement(
        Main.Maple.Key
    ),
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "key"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 8, y - 8, 16, 16)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "key"
        Main.drawSprite(ctx, "collectables/key/idle00.png", 0, 0)

        return true
    end

    return false
end

end