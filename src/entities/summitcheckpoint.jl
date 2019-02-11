module SummitCheckpoint

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Summit Checkpoint" => Ahorn.EntityPlacement(
        Maple.Checkpoint
    )
)

baseSprite = "scenery/summitcheckpoints/base02.png"

function Ahorn.selection(entity::Maple.Checkpoint)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(baseSprite, x, y)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Checkpoint, room::Maple.Room)
    checkpointIndex = get(entity.data, "number", 0)
    digit1 = floor(Int, checkpointIndex % 100 / 10)
    digit2 = checkpointIndex % 10

    Ahorn.drawSprite(ctx, baseSprite, 0, 0)
    Ahorn.drawSprite(ctx, "scenery/summitcheckpoints/numberbg0$digit1.png", -2, 4)
    Ahorn.drawSprite(ctx, "scenery/summitcheckpoints/number0$digit1.png", -2, 4)
    Ahorn.drawSprite(ctx, "scenery/summitcheckpoints/numberbg0$digit2.png", 2, 4)
    Ahorn.drawSprite(ctx, "scenery/summitcheckpoints/number0$digit2.png", 2, 4)
end

end