module PlaybackBillboard

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Playback Billboard" => Ahorn.EntityPlacement(
        Maple.PlaybackBillboard,
        "rectangle"
    ),
)

function getBillboardRectangles(room::Maple.Room)
    entities = filter(e -> e.name == "playbackBillboard", room.entities)
    rects = Ahorn.Rectangle[
        Ahorn.Rectangle(
            Int(get(e.data, "x", 0)),
            Int(get(e.data, "y", 0)),
            Int(get(e.data, "width", 8)),
            Int(get(e.data, "height", 8))
        ) for e in entities
    ]

    return rects
end

function noAdjacent(entity::Maple.PlaybackBillboard, ox::Integer, oy::Integer, rects::Array{Ahorn.Rectangle, 1})
    x, y = Ahorn.position(entity)

    rect = Ahorn.Rectangle(x + ox * 8, y + oy * 8, 8, 8)

    return !any(Ahorn.checkCollision.(rects, Ref(rect)))
end

tvSlices = "scenery/tvSlices"
fillColor = (0.17, 0.14, 0.33, 1.0)

function renderTileQuad(ctx::Ahorn.Cairo.CairoContext, sprite::Ahorn.Sprite, x::Integer, y::Integer, ix::Integer, iy::Integer)
    w, h = 8, 8
    ox, oy = sprite.offsetX, sprite.offsetY
    dx, dy = x * 8, y * 8
    ix += ox
    iy += oy

    if ix < 0
        w += ox
        dx -= ox
        ix = 0
    end

    if iy < 0
        h += oy
        dy -= oy
        iy = 0
    end

    Ahorn.drawImage(ctx, sprite, dx, dy, ix, iy, w, h)
end

function renderTile(ctx::Ahorn.Cairo.CairoContext, entity::Maple.PlaybackBillboard, x::Integer, y::Integer, rects::Array{Ahorn.Rectangle, 1}, sprite::Ahorn.Sprite)
    if noAdjacent(entity, x, y, rects)
        centerLeft = !noAdjacent(entity, x - 1, y, rects)
        centerRight = !noAdjacent(entity, x + 1, y, rects)
        topCenter = !noAdjacent(entity, x, y - 1, rects)
        bottomCenter = !noAdjacent(entity, x, y + 1, rects)
        topLeft = !noAdjacent(entity, x - 1, y - 1, rects)
        topRight = !noAdjacent(entity, x + 1, y - 1, rects)
        bottomLeft = !noAdjacent(entity, x - 1, y + 1, rects)
        bottomRight = !noAdjacent(entity, x + 1, y + 1, rects)

        if (!centerRight && !bottomCenter) && bottomRight
            renderTileQuad(ctx, sprite, x, y, 0, 0)

        elseif (!centerLeft && !bottomCenter) && bottomLeft
            renderTileQuad(ctx, sprite, x, y, 16, 0)

        elseif (!topCenter && !centerRight) && topRight
            renderTileQuad(ctx, sprite, x, y, 0, 16)

        elseif (!topCenter && !centerLeft) && topLeft
            renderTileQuad(ctx, sprite, x, y, 16, 16)

        elseif centerRight && bottomCenter
            renderTileQuad(ctx, sprite, x, y, 24, 0)

        elseif centerLeft && bottomCenter
            renderTileQuad(ctx, sprite, x, y, 32, 0)

        elseif centerRight && topCenter
            renderTileQuad(ctx, sprite, x, y, 24, 16)

        elseif centerLeft && topCenter
            renderTileQuad(ctx, sprite, x, y, 32, 16)

        elseif bottomCenter
            renderTileQuad(ctx, sprite, x, y, 8, 0)

        elseif centerRight
            renderTileQuad(ctx, sprite, x, y, 0, 8)

        elseif centerLeft
            renderTileQuad(ctx, sprite, x, y, 16, 8)

        elseif topCenter
            renderTileQuad(ctx, sprite, x, y, 8, 16)
        end
    end
end

function renderPlaybackBillboard(ctx::Ahorn.Cairo.CairoContext, entity::Maple.PlaybackBillboard, room::Maple.Room)
    tvSlicesSprite = Ahorn.getSprite(tvSlices, "Gameplay")
    billboardRectangles = getBillboardRectangles(room)
    rng = Ahorn.getSimpleEntityRng(entity)

    x, y = Ahorn.position(entity)

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    Ahorn.drawRectangle(ctx, 0, 0, width, height, fillColor)

    for i in -1:tilesWidth
        renderTile(ctx, entity, i, -1, billboardRectangles, tvSlicesSprite)
        renderTile(ctx, entity, i, tilesHeight, billboardRectangles, tvSlicesSprite)
    end

    for j in 0:tilesHeight - 1
        renderTile(ctx, entity, -1, j, billboardRectangles, tvSlicesSprite)
        renderTile(ctx, entity, tilesWidth, j, billboardRectangles, tvSlicesSprite)
    end
end

Ahorn.minimumSize(entity::Maple.PlaybackBillboard) = 16, 16
Ahorn.resizable(entity::Maple.PlaybackBillboard) = true, true

Ahorn.selection(entity::Maple.PlaybackBillboard) = Ahorn.getEntityRectangle(entity)

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.PlaybackBillboard, room::Maple.Room)
    renderPlaybackBillboard(ctx, entity, room)
end

end