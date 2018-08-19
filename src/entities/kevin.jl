module Kevin

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Kevin (Both)" => Ahorn.EntityPlacement(
        Maple.CrushBlock,
        "rectangle"
    ),
    "Kevin (Vertical)" => Ahorn.EntityPlacement(
        Maple.CrushBlock,
        "rectangle",
        Dict{String, Any}(
            "axes" => "vertical"
        )
    ),
    "Kevin (Horizontal)" => Ahorn.EntityPlacement(
        Maple.CrushBlock,
        "rectangle",
        Dict{String, Any}(
            "axes" => "horizontal"
        )
    ),
)

frameImage = Dict{String, String}(
    "none" => "objects/crushblock/block00",
    "horizontal" => "objects/crushblock/block01",
    "vertical" => "objects/crushblock/block02",
    "both" => "objects/crushblock/block03"
)

smallFace = "objects/crushblock/idle_face"
giantFace = "objects/crushblock/giant_block00"

kevinColor = (98, 34, 43) ./ 255

function editingOptions(entity::Maple.Entity)
    if entity.name == "crushBlock"
        return true, Dict{String, Any}(
            "axes" => ["both", "horizontal", "vertical"]
        )
    end
end

function minimumSize(entity::Maple.Entity)
    if entity.name == "crushBlock"
        return true, 24, 24
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "crushBlock"
        return true, true, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "crushBlock"
        x, y = Ahorn.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Ahorn.Rectangle(x, y, width, height)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    # Todo?
    # Use tiles randomness to decide on Kevin border
    if entity.name == "crushBlock"
        axes = lowercase(get(entity.data, "axes", "both"))
        chillout = get(entity.data, "chillout", false)

        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        giant = height >= 48 && width >= 48 && chillout
        face = giant? giantFace : smallFace
        frame = frameImage[lowercase(axes)]
        faceSprite = Ahorn.sprites[face]

        tilesWidth = div(width, 8)
        tilesHeight = div(height, 8)

        Ahorn.drawRectangle(ctx, 2, 2, width - 4, height - 4, kevinColor)
        Ahorn.drawImage(ctx, faceSprite, div(width - faceSprite.width, 2), div(height - faceSprite.height, 2))

        for i in 2:tilesWidth - 1
            Ahorn.drawImage(ctx, frame, (i - 1) * 8, 0, 8, 0, 8, 8)
            Ahorn.drawImage(ctx, frame, (i - 1) * 8, height - 8, 8, 24, 8, 8)
        end

        for i in 2:tilesHeight - 1
            Ahorn.drawImage(ctx, frame, 0, (i - 1) * 8, 0, 8, 8, 8)
            Ahorn.drawImage(ctx, frame, width - 8, (i - 1) * 8, 24, 8, 8, 8)
        end

        Ahorn.drawImage(ctx, frame, 0, 0, 0, 0, 8, 8)
        Ahorn.drawImage(ctx, frame, width - 8, 0, 24, 0, 8, 8)
        Ahorn.drawImage(ctx, frame, 0, height - 8, 0, 24, 8, 8)
        Ahorn.drawImage(ctx, frame, width - 8, height - 8, 24, 24, 8, 8)

        return true
    end

    return false
end

end