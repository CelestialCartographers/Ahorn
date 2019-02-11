module TempleMirror

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Temple Mirror" => Ahorn.EntityPlacement(
        Maple.TempleMirror,
        "rectangle"
    )
)

Ahorn.minimumSize(entity::Maple.TempleMirror) = 24, 24
Ahorn.resizable(entity::Maple.TempleMirror) = true, true

mirrorColor = (5, 7, 14, 1) ./ (255, 255, 255, 1)
mirrorTexture = "scenery/templemirror"

function Ahorn.selection(entity::Maple.TempleMirror)
    x, y = Ahorn.position(entity)

    width = Int(get(entity.data, "width", 48))
    height = Int(get(entity.data, "height", 32))

    return Ahorn.Rectangle(x, y, width, height)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.TempleMirror, room::Maple.Room)
    width = Int(get(entity.data, "width", 48))
    height = Int(get(entity.data, "height", 32))

    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    frame = Ahorn.getSprite(mirrorTexture, "Gameplay")

    Ahorn.drawRectangle(ctx, 2, 2, width - 4, height - 4, mirrorColor)

    for i in 2:tilesWidth - 1
        Ahorn.drawImage(ctx, frame, (i - 1) * 8, 0, 8, 0, 8, 8)
        Ahorn.drawImage(ctx, frame, (i - 1) * 8, height - 8, 8, 16, 8, 8)
    end

    for i in 2:tilesHeight - 1
        Ahorn.drawImage(ctx, frame, 0, (i - 1) * 8, 0, 8, 8, 8)
        Ahorn.drawImage(ctx, frame, width - 8, (i - 1) * 8, 16, 8, 8, 8)
    end

    Ahorn.drawImage(ctx, frame, 0, 0, 0, 0, 8, 8)
    Ahorn.drawImage(ctx, frame, width - 8, 0, 16, 0, 8, 8)
    Ahorn.drawImage(ctx, frame, 0, height - 8, 0, 16, 8, 8)
    Ahorn.drawImage(ctx, frame, width - 8, height - 8, 16, 16, 8, 8)
end

end