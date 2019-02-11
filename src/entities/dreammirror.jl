module DreamMirror

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Dream Mirror" => Ahorn.EntityPlacement(
        Maple.DreamMirror
    )
)

frame = "objects/mirror/frame.png"
glass = "objects/mirror/glassbreak00.png"

function Ahorn.selection(entity::Maple.DreamMirror)
    x, y = Ahorn.position(entity)

    return Ahorn.coverRectangles([
        Ahorn.getSpriteRectangle(frame, x, y, jx=0.5, jy=1.0),
        Ahorn.getSpriteRectangle(glass, x, y, jx=0.5, jy=1.0)
    ])
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.DreamMirror, room::Maple.Room)
    Ahorn.drawSprite(ctx, glass, 0, 0, jx=0.5, jy=1.0)
    Ahorn.drawSprite(ctx, frame, 0, 0, jx=0.5, jy=1.0)
end

end