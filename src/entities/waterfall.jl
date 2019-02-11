module Waterfall

using ..Ahorn, Maple

const fillColor = Ahorn.XNAColors.LightBlue .* 0.3
const surfaceColor = Ahorn.XNAColors.LightBlue .* 0.8

const waterSegmentMatrix = [
    1 0 0 0 0 0 0 1 1 1;
    1 0 0 0 0 0 0 1 1 1;
    1 0 0 0 0 0 0 1 1 1;
    1 0 0 0 0 0 0 1 1 1;
    1 0 0 0 0 0 0 1 1 1;
    1 0 0 0 0 0 0 1 1 1;
    1 0 0 0 0 0 0 1 1 1;
    1 0 0 0 0 0 0 1 1 1;
    1 1 0 0 0 0 0 0 1 1;
    1 1 0 0 0 0 0 0 1 1;
    1 1 1 0 0 0 0 0 0 1;
    1 1 1 0 0 0 0 0 0 1;
    1 1 1 0 0 0 0 0 0 1;
    1 1 1 0 0 0 0 0 0 1;
    1 1 1 0 0 0 0 0 0 1;
    1 1 1 0 0 0 0 0 0 1;
    1 1 1 0 0 0 0 0 0 1;
    1 1 1 0 0 0 0 0 0 1;
    1 1 0 0 0 0 0 0 1 1;
    1 1 0 0 0 0 0 0 1 1;
    1 1 0 0 0 0 0 0 1 1;
]

const waterSegment = Ahorn.matrixToSurface(
    waterSegmentMatrix,
    [
        fillColor,
        surfaceColor
    ]
)

function getHeight(entity::Maple.Waterfall, room::Maple.Room)
    waterEntities = filter(e -> e.name == "water", room.entities)
    waterRects = Ahorn.Rectangle[
        Ahorn.Rectangle(
            Int(get(e.data, "x", 0)),
            Int(get(e.data, "y", 0)),
            Int(get(e.data, "width", 8)),
            Int(get(e.data, "height", 8))
        ) for e in waterEntities
    ]

    width, height = room.size
    x, y = Int(get(entity.data, "x", 0)), Int(get(entity.data, "y", 0))
    tx, ty = floor(Int, x / 8) + 1, floor(Int, y / 8) + 1

    wantedHeight = 8 - y % 8
    while wantedHeight < height - y
        rect = Ahorn.Rectangle(x, y + wantedHeight, 8, 8)

        if any(Ahorn.checkCollision.(waterRects, Ref(rect)))
            break
        end

        if get(room.fgTiles.data, (ty + 1, tx), '0') != '0'
            break
        end

        wantedHeight += 8
        ty += 1
    end

    return wantedHeight
end

const placements = Ahorn.PlacementDict(
    "Waterfall" => Ahorn.EntityPlacement(
        Maple.Waterfall
    )
)

function Ahorn.selection(entity::Maple.Waterfall, room::Maple.Room)
    x, y = Ahorn.position(entity)
    height = getHeight(entity, room)

    return Ahorn.Rectangle(x, y, size(waterSegmentMatrix, 2), height)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Waterfall, room::Maple.Room)
    x = Int(get(entity.data, "x", 0))
    y = Int(get(entity.data, "y", 0))

    height = getHeight(entity, room)
    segmentHeight, segmentWidth = size(waterSegmentMatrix)

    Ahorn.Cairo.save(ctx)

    Ahorn.rectangle(ctx, 0, 0, segmentWidth, height)
    Ahorn.clip(ctx)

    for i in 0:segmentHeight:ceil(Int, height / segmentHeight) * segmentHeight
        Ahorn.drawImage(ctx, waterSegment, 0, i)
    end
    
    Ahorn.restore(ctx)
end

end