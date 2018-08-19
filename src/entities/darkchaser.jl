module DarkChaser

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Badeline Chaser" => Ahorn.EntityPlacement(
        Maple.DarkChaser
    ),

    "Badeline Chaser Barrier" => Ahorn.EntityPlacement(
        Maple.DarkChaserEnd,
        "rectangle"
    ),
)

function minimumSize(entity::Maple.Entity)
    if entity.name == "darkChaserEnd"
        return true, 8, 8
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "darkChaserEnd"
        return true, true, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "darkChaser"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 2, y - 16, 12, 16)
        
    elseif entity.name == "darkChaserEnd"
        x, y = Ahorn.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Ahorn.Rectangle(x, y, width, height)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity)
    if entity.name == "darkChaser"
        Ahorn.drawSprite(ctx, "characters/badeline/sleep00.png", 4, -16)

        return true

    elseif entity.name == "darkChaserEnd"
        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        Ahorn.drawRectangle(ctx, 0, 0, width, height, (0.4, 0.0, 0.4, 0.4), (0.4, 0.0, 0.4, 1.0))

        return true
    end

    return false
end

end