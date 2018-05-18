module SwapBlock

function swapFinalizer(entity)
    x, y = Main.entityTranslation(entity)

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))

    entity.data["nodes"] = [(x + width, y)]
end

placements = Dict{String, Main.EntityPlacement}(
    "Swap Block" => Main.EntityPlacement(
        Main.Maple.SwapBlock,
        "rectangle",
        Dict{String, Any}(),
        swapFinalizer
    )
)

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "swapBlock"
        return true, 1, 1
    end
end

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "swapBlock"
        return true, 16, 16
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "swapBlock"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "swapBlock"
        x, y = Main.entityTranslation(entity)
        stopX, stopY = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, [Main.Rectangle(x, y, width, height), Main.Rectangle(stopX, stopY, width, height)]
    end
end

frame = "objects/swapblock/blockRed"
trailFrame = "objects/swapblock/target"
midSprite = Main.sprites["objects/swapblock/midBlockRed00"]

function renderTrail(ctx, x::Number, y::Number, width::Number, height::Number)
    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    for i in 2:tilesWidth - 1
        Main.drawImage(ctx, trailFrame, x + (i - 1) * 8, y + 2, 6, 0, 8, 6)
        Main.drawImage(ctx, trailFrame, x + (i - 1) * 8, y + height - 8, 6, 14, 8, 6)
    end

    for i in 2:tilesHeight - 1
        Main.drawImage(ctx, trailFrame, x + 2, y + (i - 1) * 8, 0, 6, 8, 8)
        Main.drawImage(ctx, trailFrame, x + width - 8, y + (i - 1) * 8, 14, 6, 8, 8)
    end

    for i in 2:tilesWidth - 1, j in 2:tilesHeight - 1
        Main.drawImage(ctx, trailFrame, x + (i - 1) * 8, y + (j - 1) * 8, 6, 6, 8, 8)
    end

    Main.drawImage(ctx, trailFrame, x + width - 8, y + 2, 14, 0, 6, 6)
    Main.drawImage(ctx, trailFrame, x + width - 8, y + height - 8, 14, 14, 6, 6)
    Main.drawImage(ctx, trailFrame, x + 2, y + 2, 0, 0, 6, 6)
    Main.drawImage(ctx, trailFrame, x + 2, y + height - 8, 0, 14, 6, 6)
end

function renderSwapBlock(ctx::Main.Cairo.CairoContext, x::Number, y::Number, width::Number, height::Number)
    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    for i in 2:tilesWidth - 1
        Main.drawImage(ctx, frame, x + (i - 1) * 8, y, 8, 0, 8, 8)
        Main.drawImage(ctx, frame, x + (i - 1) * 8, y + height - 8, 8, 16, 8, 8)
    end

    for i in 2:tilesHeight - 1
        Main.drawImage(ctx, frame, x, y + (i - 1) * 8, 0, 8, 8, 8)
        Main.drawImage(ctx, frame, x + width - 8, y + (i - 1) * 8, 16, 8, 8, 8)
    end

    for i in 2:tilesWidth - 1, j in 2:tilesHeight - 1
        Main.drawImage(ctx, frame, x + (i - 1) * 8, y + (j - 1) * 8, 8, 8, 8, 8)
    end

    Main.drawImage(ctx, frame, x, y, 0, 0, 8, 8)
    Main.drawImage(ctx, frame, x + width - 8, y, 16, 0, 8, 8)
    Main.drawImage(ctx, frame, x, y + height - 8, 0, 16, 8, 8)
    Main.drawImage(ctx, frame, x + width - 8, y + height - 8, 16, 16, 8, 8)

    Main.drawImage(ctx, midSprite, x + div(width - midSprite.width, 2), y + div(height - midSprite.height, 2))
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "swapBlock"
        sprite = get(entity.data, "sprite", "block")
        startX, startY = Int(entity.data["x"]), Int(entity.data["y"])
        stopX, stopY = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        renderSwapBlock(ctx, stopX, stopY, width, height)
        Main.drawArrow(ctx, startX + width / 2, startY + height / 2, stopX + width / 2, stopY + height / 2, Main.colors.selection_selected_fc, headLength=6)

        return true
    end
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
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