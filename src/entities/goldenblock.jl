module GoldenBlock

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Golden Block" => Ahorn.EntityPlacement(
        Maple.GoldenBlock,
        "rectangle"
    ),
)

frame = "objects/goldblock"
strawberry = "collectables/goldberry/idle00"

Ahorn.minimumSize(entity::Maple.GoldenBlock) = 16, 16
Ahorn.resizable(entity::Maple.GoldenBlock) = true, true

Ahorn.selection(entity::Maple.GoldenBlock) = Ahorn.getEntityRectangle(entity)

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.GoldenBlock, room::Maple.Room)
    x, y = Ahorn.position(entity)

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    for i in 2:tilesWidth - 1
        Ahorn.drawImage(ctx, frame, (i - 1) * 8, 0, 8, 0, 8, 8)
        Ahorn.drawImage(ctx, frame, (i - 1) * 8, height - 8, 8, 16, 8, 8)
    end

    for i in 2:tilesHeight - 1
        Ahorn.drawImage(ctx, frame, 0, (i - 1) * 8, 0, 8, 8, 8)
        Ahorn.drawImage(ctx, frame, width - 8, (i - 1) * 8, 16, 8, 8, 8)
    end

    for i in 2:tilesWidth - 1, j in 2:tilesHeight - 1
        Ahorn.drawImage(ctx, frame, (i - 1) * 8, (j - 1) * 8, 8, 8, 8, 8)
    end

    Ahorn.drawImage(ctx, frame, 0, 0, 0, 0, 8, 8)
    Ahorn.drawImage(ctx, frame, width - 8, 0, 16, 0, 8, 8)
    Ahorn.drawImage(ctx, frame, 0, height - 8, 0, 16, 8, 8)
    Ahorn.drawImage(ctx, frame, width - 8, height - 8, 16, 16, 8, 8)

    Ahorn.drawSprite(ctx, strawberry, width / 2, height / 2)
end

end