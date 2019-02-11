module Gondola

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Gondola" => Ahorn.EntityPlacement(
        Maple.Gondola,
        "line",
    )
)

frontSprite = "objects/gondola/front"
backSprite = "objects/gondola/back"
topSprite = "objects/gondola/top"
leverSprite = "objects/gondola/lever01"
leftSprite = "objects/gondola/cliffsideLeft"
rightSprite = "objects/gondola/cliffsideRight"

renderOffsetY = -64

Ahorn.nodeLimits(entity::Maple.Gondola) = 1, 1

function Ahorn.selection(entity::Maple.Gondola)
    x, y = Ahorn.position(entity)
    nodes = get(entity.data, "nodes", ((x + 128, y + 128)))
    destX, destY = Int.(nodes[1])

    return Ahorn.Rectangle[
        Ahorn.getSpriteRectangle(frontSprite, x, y + renderOffsetY, jx=0.5, jy=0.0),
        Ahorn.getSpriteRectangle(rightSprite, destX + 144, destY - 104, jx=0.0, jy=0.5, sx=-1)
    ]
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Gondola, room::Maple.Room)
    x, y = Ahorn.position(entity)

    nodes = get(entity.data, "nodes", ())

    if !isempty(nodes)
        top = Ahorn.getSprite(topSprite, "Gameplay")

        destX, destY = Int.(nodes[1])

        wireLeftX = x - 124 + 40
        wireLeftY = y - 12

        wireRightX = destX + 144 - 40
        wireRightY = destY - 104 - 4

        topX = x
        topY = y + renderOffsetY + top.height

        Ahorn.Cairo.save(ctx)

        Ahorn.setSourceColor(ctx, (0.0, 0.0, 0.0, 1.0))
        Ahorn.set_antialias(ctx, 1)
        Ahorn.set_line_width(ctx, 1);

        for i in 0:1
            Ahorn.move_to(ctx, wireLeftX, wireLeftY + i)
            Ahorn.line_to(ctx, topX, topY + i)

            Ahorn.stroke(ctx)

            Ahorn.move_to(ctx, topX, topY + i)
            Ahorn.line_to(ctx, wireRightX, wireRightY + i)

            Ahorn.stroke(ctx)
        end

        # Don't rotate the top sprite, it's super broken in game
        Ahorn.drawSprite(ctx, frontSprite, x, y + renderOffsetY, jx=0.5, jy=0.0)
        Ahorn.drawSprite(ctx, topSprite, x, y + renderOffsetY, jx=0.5, jy=0.0)
        Ahorn.drawSprite(ctx, leverSprite, x, y + renderOffsetY, jx=0.5, jy=0.0)
        Ahorn.drawSprite(ctx, backSprite, x, y + renderOffsetY, jx=0.5, jy=0.0)

        Ahorn.drawSprite(ctx, leftSprite, x - 124, y, jx=0.0, jy=1.0)
        Ahorn.drawSprite(ctx, rightSprite, destX + 144, destY - 104, jx=0.0, jy=0.5, sx=-1)

        Ahorn.Cairo.restore(ctx)
    end
end

end