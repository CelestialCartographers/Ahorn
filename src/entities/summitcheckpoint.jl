module SummitCheckpoint

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Summit Checkpoint" => Ahorn.EntityPlacement(
        Maple.Checkpoint
    )
)

function selection(entity::Maple.Entity)
    if entity.name == "summitcheckpoint"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 6, y - 11, 11, 22)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "summitcheckpoint"
        checkpointIndex = get(entity.data, "number", 0)
        digit1 = floor(Int, checkpointIndex % 100 / 10)
        digit2 = checkpointIndex % 10

        Ahorn.drawSprite(ctx, "scenery/summitcheckpoints/base02.png", 0, 0)
        Ahorn.drawSprite(ctx, "scenery/summitcheckpoints/numberbg0$digit1.png", -2, 4)
        Ahorn.drawSprite(ctx, "scenery/summitcheckpoints/number0$digit1.png", -2, 4)
        Ahorn.drawSprite(ctx, "scenery/summitcheckpoints/numberbg0$digit2.png", 2, 4)
        Ahorn.drawSprite(ctx, "scenery/summitcheckpoints/number0$digit2.png", 2, 4)

        return true
    end

    return false
end

end