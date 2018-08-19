module Spring

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Spring (Up)" => Ahorn.EntityPlacement(
        Maple.Spring
    ),
    "Spring (Left)" => Ahorn.EntityPlacement(
        Maple.SpringRight
    ),
    "Spring (Right)" => Ahorn.EntityPlacement(
        Maple.SpringLeft
    ),
)

function selection(entity::Maple.Entity)
    x, y = Ahorn.entityTranslation(entity)

    if entity.name == "spring"
        return true, Ahorn.Rectangle(x - 6, y - 3, 12, 5)

    elseif entity.name == "wallSpringLeft"
        return true, Ahorn.Rectangle(x - 1, y - 6, 5, 12)

    elseif entity.name == "wallSpringRight"
        return true, Ahorn.Rectangle(x - 4, y - 6, 5, 12)
    end

    return false
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "spring"
        Ahorn.drawSprite(ctx, "objects/spring/00.png", 0, -8)

        return true

    elseif entity.name == "wallSpringLeft"
        Ahorn.drawSprite(ctx, "objects/spring/00.png", 9, -11, rot=pi / 2)

        return true

    elseif entity.name == "wallSpringRight"
        Ahorn.drawSprite(ctx, "objects/spring/00.png", 3, 1, rot=-pi / 2)

        return true
    end

    return false
end

end