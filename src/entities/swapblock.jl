module SwapBlock

using ..Ahorn, Maple

function swapFinalizer(entity)
    x, y = Ahorn.entityTranslation(entity)

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))

    entity.data["nodes"] = [(x + width, y)]
end

placements = Dict{String, Ahorn.EntityPlacement}(
    "Swap Block" => Ahorn.EntityPlacement(
        Maple.SwapBlock,
        "rectangle",
        Dict{String, Any}(),
        swapFinalizer
    )
)

function nodeLimits(entity::Maple.Entity)
    if entity.name == "swapBlock"
        return true, 1, 1
    end
end

function minimumSize(entity::Maple.Entity)
    if entity.name == "swapBlock"
        return true, 16, 16
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "swapBlock"
        return true, true, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "swapBlock"
        x, y = Ahorn.entityTranslation(entity)
        stopX, stopY = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, [Ahorn.Rectangle(x, y, width, height), Ahorn.Rectangle(stopX, stopY, width, height)]
    end
end

frame = "objects/swapblock/blockRed"
trailFrame = "objects/swapblock/target"
midResource = "objects/swapblock/midBlockRed00"

function renderTrail(ctx, x::Number, y::Number, width::Number, height::Number)
    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    for i in 2:tilesWidth - 1
        Ahorn.drawImage(ctx, trailFrame, x + (i - 1) * 8, y + 2, 6, 0, 8, 6)
        Ahorn.drawImage(ctx, trailFrame, x + (i - 1) * 8, y + height - 8, 6, 14, 8, 6)
    end

    for i in 2:tilesHeight - 1
        Ahorn.drawImage(ctx, trailFrame, x + 2, y + (i - 1) * 8, 0, 6, 8, 8)
        Ahorn.drawImage(ctx, trailFrame, x + width - 8, y + (i - 1) * 8, 14, 6, 8, 8)
    end

    for i in 2:tilesWidth - 1, j in 2:tilesHeight - 1
        Ahorn.drawImage(ctx, trailFrame, x + (i - 1) * 8, y + (j - 1) * 8, 6, 6, 8, 8)
    end

    Ahorn.drawImage(ctx, trailFrame, x + width - 8, y + 2, 14, 0, 6, 6)
    Ahorn.drawImage(ctx, trailFrame, x + width - 8, y + height - 8, 14, 14, 6, 6)
    Ahorn.drawImage(ctx, trailFrame, x + 2, y + 2, 0, 0, 6, 6)
    Ahorn.drawImage(ctx, trailFrame, x + 2, y + height - 8, 0, 14, 6, 6)
end

function renderSwapBlock(ctx::Ahorn.Cairo.CairoContext, x::Number, y::Number, width::Number, height::Number)
    midSprite = Ahorn.sprites[midResource]
    
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

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "swapBlock"
        sprite = get(entity.data, "sprite", "block")
        startX, startY = Int(entity.data["x"]), Int(entity.data["y"])
        stopX, stopY = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        renderSwapBlock(ctx, stopX, stopY, width, height)
        Ahorn.drawArrow(ctx, startX + width / 2, startY + height / 2, stopX + width / 2, stopY + height / 2, Ahorn.colors.selection_selected_fc, headLength=6)

        return true
    end
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "swapBlock"
        sprite = get(entity.data, "sprite", "block")

        startX, startY = Int(entity.data["x"]), Int(entity.data["y"])
        stopX, stopY = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        renderTrail(ctx, min(startX, stopX), min(startY, stopY), abs(startX - stopX) + width, abs(startY - stopY) + height)
        renderSwapBlock(ctx, startX, startY, width, height)

        return true
    end

    return false
end

end