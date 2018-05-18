module OshiroBoss

placements = Dict{String, Main.EntityPlacement}(
    "Oshiro Boss" => Main.EntityPlacement(
        Main.Maple.FriendlyGhost
    )
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "friendlyGhost"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 15, y - 16, 30, 40)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "friendlyGhost"
        Main.drawSprite(ctx, "characters/oshiro/boss13.png", 0, 0)

        return true
    end

    return false
end

end