module WhiteBlock

placements = Dict{String, Main.EntityPlacement}(
    "White Block" => Main.EntityPlacement(
        Main.Maple.WhiteBlock
    )
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "whiteblock"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x, y, 48, 24)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "whiteblock"
        Main.drawSprite(ctx, "objects/whiteblock.png", 24, 12)

        return true
    end

    return false
end

end