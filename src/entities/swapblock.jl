module SwapBlock

using ..Ahorn, Maple

function swapFinalizer(entity)
    x, y = Ahorn.position(entity)

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))

    entity.data["nodes"] = [(x + width, y)]
end

const placements = Ahorn.PlacementDict(
    "Swap Block ($(uppercasefirst(theme)))" => Ahorn.EntityPlacement(
        Maple.SwapBlock,
        "rectangle",
        Dict{String, Any}(
            "theme" => theme
        ),
        swapFinalizer
    ) for theme in Maple.swap_block_themes
)

Ahorn.editingOptions(entity::Maple.SwapBlock) = Dict{String, Any}(
    "theme" => Maple.swap_block_themes
)

Ahorn.nodeLimits(entity::Maple.SwapBlock) = 1, 1

Ahorn.minimumSize(entity::Maple.SwapBlock) = 16, 16
Ahorn.resizable(entity::Maple.SwapBlock) = true, true

function Ahorn.selection(entity::Maple.SwapBlock)
    x, y = Ahorn.position(entity)
    stopX, stopY = Int.(entity.data["nodes"][1])

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))

    return [Ahorn.Rectangle(x, y, width, height), Ahorn.Rectangle(stopX, stopY, width, height)]
end

function getTextures(entity::Maple.SwapBlock)
    theme = lowercase(get(entity, "theme", "normal"))

    if theme == "moon"
        return "objects/swapblock/moon/blockRed", "objects/swapblock/moon/target", "objects/swapblock/moon/midBlockRed00"
    end

    return "objects/swapblock/blockRed", "objects/swapblock/target", "objects/swapblock/midBlockRed00"
end

function renderTrail(ctx, x::Number, y::Number, width::Number, height::Number, trail::String)
    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    for i in 2:tilesWidth - 1
        Ahorn.drawImage(ctx, trail, x + (i - 1) * 8, y + 2, 6, 0, 8, 6)
        Ahorn.drawImage(ctx, trail, x + (i - 1) * 8, y + height - 8, 6, 14, 8, 6)
    end

    for i in 2:tilesHeight - 1
        Ahorn.drawImage(ctx, trail, x + 2, y + (i - 1) * 8, 0, 6, 6, 8)
        Ahorn.drawImage(ctx, trail, x + width - 8, y + (i - 1) * 8, 14, 6, 6, 8)
    end

    for i in 2:tilesWidth - 1, j in 2:tilesHeight - 1
        Ahorn.drawImage(ctx, trail, x + (i - 1) * 8, y + (j - 1) * 8, 6, 6, 8, 8)
    end

    Ahorn.drawImage(ctx, trail, x + width - 8, y + 2, 14, 0, 6, 6)
    Ahorn.drawImage(ctx, trail, x + width - 8, y + height - 8, 14, 14, 6, 6)
    Ahorn.drawImage(ctx, trail, x + 2, y + 2, 0, 0, 6, 6)
    Ahorn.drawImage(ctx, trail, x + 2, y + height - 8, 0, 14, 6, 6)
end

function renderSwapBlock(ctx::Ahorn.Cairo.CairoContext, x::Number, y::Number, width::Number, height::Number, midResource::String, frame::String)
    midSprite = Ahorn.getSprite(midResource, "Gameplay")
    
    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    for i in 2:tilesWidth - 1
        Ahorn.drawImage(ctx, frame, x + (i - 1) * 8, y, 8, 0, 8, 8)
        Ahorn.drawImage(ctx, frame, x + (i - 1) * 8, y + height - 8, 8, 16, 8, 8)
    end

    for i in 2:tilesHeight - 1
        Ahorn.drawImage(ctx, frame, x, y + (i - 1) * 8, 0, 8, 8, 8)
        Ahorn.drawImage(ctx, frame, x + width - 8, y + (i - 1) * 8, 16, 8, 8, 8)
    end

    for i in 2:tilesWidth - 1, j in 2:tilesHeight - 1
        Ahorn.drawImage(ctx, frame, x + (i - 1) * 8, y + (j - 1) * 8, 8, 8, 8, 8)
    end

    Ahorn.drawImage(ctx, frame, x, y, 0, 0, 8, 8)
    Ahorn.drawImage(ctx, frame, x + width - 8, y, 16, 0, 8, 8)
    Ahorn.drawImage(ctx, frame, x, y + height - 8, 0, 16, 8, 8)
    Ahorn.drawImage(ctx, frame, x + width - 8, y + height - 8, 16, 16, 8, 8)

    Ahorn.drawImage(ctx, midSprite, x + div(width - midSprite.width, 2), y + div(height - midSprite.height, 2))
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.SwapBlock, room::Maple.Room)
    sprite = get(entity.data, "sprite", "block")
    startX, startY = Int(entity.data["x"]), Int(entity.data["y"])
    stopX, stopY = Int.(entity.data["nodes"][1])

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    frame, trail, mid = getTextures(entity)

    renderSwapBlock(ctx, stopX, stopY, width, height, mid, frame)
    Ahorn.drawArrow(ctx, startX + width / 2, startY + height / 2, stopX + width / 2, stopY + height / 2, Ahorn.colors.selection_selected_fc, headLength=6)
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.SwapBlock, room::Maple.Room)
    sprite = get(entity.data, "sprite", "block")

    startX, startY = Int(entity.data["x"]), Int(entity.data["y"])
    stopX, stopY = Int.(entity.data["nodes"][1])

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    frame, trail, mid = getTextures(entity)

    renderTrail(ctx, min(startX, stopX), min(startY, stopY), abs(startX - stopX) + width, abs(startY - stopY) + height, trail)
    renderSwapBlock(ctx, startX, startY, width, height, mid, frame)
end

end