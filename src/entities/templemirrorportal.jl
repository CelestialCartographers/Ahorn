module TempleMirrorPortal

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Temple Mirror Portal" => Ahorn.EntityPlacement(
        Maple.TempleMirrorPortal
    )
)

frameSprite = "objects/temple/portal/portalframe.png"
curtainSprite = "objects/temple/portal/portalcurtain00.png"
torchSprite = "objects/temple/portal/portaltorch00.png"

torchOffset = 90

function Ahorn.selection(entity::Maple.TempleMirrorPortal)
    x, y = Ahorn.position(entity)

    return Ahorn.coverRectangles([
        Ahorn.getSpriteRectangle(frameSprite, x, y),
        Ahorn.getSpriteRectangle(curtainSprite, x, y),
        Ahorn.getSpriteRectangle(torchSprite, x - torchOffset, y, jx=0.5, jy=0.75),
        Ahorn.getSpriteRectangle(torchSprite, x + torchOffset, y, jx=0.5, jy=0.75)
    ])
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.TempleMirrorPortal, room::Maple.Room)
    Ahorn.drawSprite(ctx, frameSprite, 0, 0)
    Ahorn.drawSprite(ctx, curtainSprite, 0, 0)

    Ahorn.drawSprite(ctx, torchSprite, -torchOffset, 0, jx=0.5, jy=0.75)
    Ahorn.drawSprite(ctx, torchSprite, torchOffset, 0, jx=0.5, jy=0.75)
end

end