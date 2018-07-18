module SummitCheckpoint

placements = Dict{String, Main.EntityPlacement}(
    "Summit Checkpoint" => Main.EntityPlacement(
        Main.Maple.Checkpoint
    )
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "summitcheckpoint"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 6, y - 11, 11, 22)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "summitcheckpoint"
        checkpointIndex = get(entity.data, "number", 0)
        digit1 = floor(Int, checkpointIndex % 100 / 10)
        digit2 = checkpointIndex % 10

        Main.drawSprite(ctx, "scenery/summitcheckpoints/base02.png", 0, 0)
        Main.drawSprite(ctx, "scenery/summitcheckpoints/numberbg0$digit1.png", -2, 4)
        Main.drawSprite(ctx, "scenery/summitcheckpoints/number0$digit1.png", -2, 4)
        Main.drawSprite(ctx, "scenery/summitcheckpoints/numberbg0$digit2.png", 2, 4)
        Main.drawSprite(ctx, "scenery/summitcheckpoints/number0$digit2.png", 2, 4)

        return true
    end

    return false
end

end