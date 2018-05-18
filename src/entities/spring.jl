module Spring

placements = Dict{String, Main.EntityPlacement}(
    "Spring (Up)" => Main.EntityPlacement(
        Main.Maple.Spring
    ),
    "Spring (Left)" => Main.EntityPlacement(
        Main.Maple.SpringRight
    ),
    "Spring (Right)" => Main.EntityPlacement(
        Main.Maple.SpringLeft
    ),
)

function selection(entity::Main.Maple.Entity)
    x, y = Main.entityTranslation(entity)

    if entity.name == "spring"
        return true, Main.Rectangle(x - 6, y - 3, 12, 5)

    elseif entity.name == "wallSpringLeft"
        return true, Main.Rectangle(x - 1, y - 6, 5, 12)

    elseif entity.name == "wallSpringRight"
        return true, Main.Rectangle(x - 4, y - 6, 5, 12)
    end

    return false
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "spring"
        Main.drawSprite(ctx, "objects/spring/00.png", 0, -8)

        return true

    elseif entity.name == "wallSpringLeft"
        Main.drawSprite(ctx, "objects/spring/00.png", 9, -11, rot=pi / 2)

        return true

    elseif entity.name == "wallSpringRight"
        Main.drawSprite(ctx, "objects/spring/00.png", 3, 1, rot=-pi / 2)

        return true
    end

    return false
end

end