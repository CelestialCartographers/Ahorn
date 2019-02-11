module ResortMirror

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Resort Mirror" => Ahorn.EntityPlacement(
        Maple.ResortMirror
    )
)

function Ahorn.selection(entity::Maple.ResortMirror)
    x, y = Ahorn.position(entity)
    frameSprite = Ahorn.getSprite("objects/mirror/resortframe", "Gameplay")

    return Ahorn.Rectangle(x - frameSprite.width / 2, y - frameSprite.height, frameSprite.width, frameSprite.height)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.ResortMirror, room::Maple.Room)
    frameSprite = Ahorn.getSprite("objects/mirror/resortframe", "Gameplay")
    glassSprite = Ahorn.getSprite("objects/mirror/glassbreak00", "Gameplay")

    glassWidth = frameSprite.width - 4
    glassHeight = frameSprite.height - 8

    Ahorn.drawImage(ctx, glassSprite, -glassHeight / 2, -glassHeight, (glassSprite.width - glassWidth) / 2, glassSprite.height - glassHeight, glassWidth, glassHeight)
    Ahorn.drawImage(ctx, frameSprite, -frameSprite.width / 2, -frameSprite.height)
end

end