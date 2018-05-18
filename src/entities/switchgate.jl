module SwitchGate

function gateFinalizer(entity)
    x, y = Main.entityTranslation(entity)

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))

    entity.data["nodes"] = [(x + width, y)]
end

placements = Dict{String, Main.EntityPlacement}(
    "Switch Gate (Stone)" => Main.EntityPlacement(
        Main.Maple.SwitchGate,
        "rectangle",
        Dict{String, Any}(
            "sprite" => "block"
        ),
        gateFinalizer
    ),
    "Switch Gate (Mirror)" => Main.EntityPlacement(
        Main.Maple.SwitchGate,
        "rectangle",
        Dict{String, Any}(
            "sprite" => "mirror"
        ),
        gateFinalizer
    ),
    "Switch Gate (Temple)" => Main.EntityPlacement(
        Main.Maple.SwitchGate,
        "rectangle",
        Dict{String, Any}(
            "sprite" => "temple"
        ),
        gateFinalizer
    ),

    "Touch Switch" => Main.EntityPlacement(
        Main.Maple.TouchSwitch
    )
)

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "switchGate"
        return true, 1, 1
    end
end

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "switchGate"
        return true, 16, 16
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "switchGate"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "switchGate"
        x, y = Main.entityTranslation(entity)
        stopX, stopY = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, [Main.Rectangle(x, y, width, height), Main.Rectangle(stopX, stopY, width, height)]

    elseif entity.name == "touchSwitch"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 7, y - 7, 14, 14)
    end
end

iconSprite = Main.sprites["objects/switchgate/icon00"]

function renderGateSwitch(ctx::Main.Cairo.CairoContext, x::Number, y::Number, width::Number, height::Number, sprite::String)
    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    frame = "objects/switchgate/$sprite"

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

    Main.drawImage(ctx, iconSprite, x + div(width - iconSprite.width, 2), y + div(height - iconSprite.height, 2))
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "switchGate"
        sprite = get(entity.data, "sprite", "block")
        startX, startY = Int(entity.data["x"]), Int(entity.data["y"])
        stopX, stopY = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        renderGateSwitch(ctx, stopX, stopY, width, height, sprite)
        Main.drawArrow(ctx, startX + width / 2, startY + height / 2, stopX + width / 2, stopY + height / 2, Main.colors.selection_selected_fc, headLength=6)

        return true
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "touchSwitch"
        Main.drawSprite(ctx, "objects/touchswitch/container.png", 0, 0)
        Main.drawSprite(ctx, "objects/touchswitch/icon00.png", 0, 0)
        
        return true
    end
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "switchGate"
        sprite = get(entity.data, "sprite", "block")

        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        renderGateSwitch(ctx, x, y, width, height, sprite)

        return true
    end

    return false
end

end