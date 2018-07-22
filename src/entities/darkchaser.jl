module DarkChaser

placements = Dict{String, Main.EntityPlacement}(
    "Badeline Chaser" => Main.EntityPlacement(
        Main.Maple.DarkChaser
    ),

    "Badeline Chaser Barrier" => Main.EntityPlacement(
        Main.Maple.DarkChaserEnd,
        "rectangle"
    ),
)

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "darkChaserEnd"
        return true, 8, 8
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "darkChaserEnd"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "darkChaser"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 2, y - 16, 12, 16)
        
    elseif entity.name == "darkChaserEnd"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Main.Rectangle(x, y, width, height)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity)
    if entity.name == "darkChaser"
        Main.drawSprite(ctx, "characters/badeline/sleep00.png", 4, -16)

        return true

    elseif entity.name == "darkChaserEnd"
        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        Main.drawRectangle(ctx, 0, 0, width, height, (0.4, 0.0, 0.4, 0.4), (0.4, 0.0, 0.4, 1.0))

        return true
    end

    return false
end

end