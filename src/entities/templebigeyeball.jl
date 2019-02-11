module TempleBigEyeball

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Temple Big Eyeball" => Ahorn.EntityPlacement(
        Maple.TempleBigEyeball
    )
)

bodySprite = "danger/templeeye/body00.png"
pupilSprite = "danger/templeeye/pupil.png"

function Ahorn.selection(entity::Maple.TempleBigEyeball)
    x, y = Ahorn.position(entity)

    return Ahorn.coverRectangles([
        Ahorn.getSpriteRectangle(bodySprite, x, y),
        Ahorn.getSpriteRectangle(pupilSprite, x, y)
    ])
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.TempleBigEyeball, room::Maple.Room)
    Ahorn.drawSprite(ctx, bodySprite, 0, 0)
    Ahorn.drawSprite(ctx, pupilSprite, 0, 0)
end

end