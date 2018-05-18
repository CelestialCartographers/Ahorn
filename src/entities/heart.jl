module Heart

placements = Dict{String, Main.EntityPlacement}(
    "Crystal Heart" => Main.EntityPlacement(
        Main.Maple.CrystalHeart
    ),
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "blackGem"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 8, y - 8, 16, 16)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "blackGem"
        Main.drawSprite(ctx, "collectables/heartGem/0/00.png", 0, 0)

        return true
    end

    return false
end

end