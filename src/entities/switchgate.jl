module SwitchGate

using ..Ahorn, Maple

function gateFinalizer(entity)
    x, y = Ahorn.entityTranslation(entity)

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))

    entity.data["nodes"] = [(x + width, y)]
end

textures = ["block", "mirror", "temple"]

placements = Dict{String, Ahorn.EntityPlacement}(
    "Switch Gate (Stone)" => Ahorn.EntityPlacement(
        Maple.SwitchGate,
        "rectangle",
        Dict{String, Any}(
            "sprite" => "block"
        ),
        gateFinalizer
    ),
    "Switch Gate (Mirror)" => Ahorn.EntityPlacement(
        Maple.SwitchGate,
        "rectangle",
        Dict{String, Any}(
            "sprite" => "mirror"
        ),
        gateFinalizer
    ),
    "Switch Gate (Temple)" => Ahorn.EntityPlacement(
        Maple.SwitchGate,
        "rectangle",
        Dict{String, Any}(
            "sprite" => "temple"
        ),
        gateFinalizer
    ),

    "Touch Switch" => Ahorn.EntityPlacement(
        Maple.TouchSwitch
    )
)

function editingOptions(entity::Maple.Entity)
    if entity.name == "switchGates"
        return true, Dict{String, Any}(
            "sprite" => textures
        )
    end
end

function nodeLimits(entity::Maple.Entity)
    if entity.name == "switchGate"
        return true, 1, 1
    end
end

function minimumSize(entity::Maple.Entity)
    if entity.name == "switchGate"
        return true, 16, 16
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "switchGate"
        return true, true, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "switchGate"
        x, y = Ahorn.entityTranslation(entity)
        stopX, stopY = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, [Ahorn.Rectangle(x, y, width, height), Ahorn.Rectangle(stopX, stopY, width, height)]

    elseif entity.name == "touchSwitch"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 7, y - 7, 14, 14)
    end
end

iconResource = "objects/switchgate/icon00"

function renderGateSwitch(ctx::Ahorn.Cairo.CairoContext, x::Number, y::Number, width::Number, height::Number, sprite::String)
    iconSprite = Ahorn.sprites[iconResource]
    
    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    frame = "objects/switchgate/$sprite"

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

    Ahorn.drawImage(ctx, iconSprite, x + div(width - iconSprite.width, 2), y + div(height - iconSprite.height, 2))
end

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "switchGate"
        sprite = get(entity.data, "sprite", "block")
        startX, startY = Int(entity.data["x"]), Int(entity.data["y"])
        stopX, stopY = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        renderGateSwitch(ctx, stopX, stopY, width, height, sprite)
        Ahorn.drawArrow(ctx, startX + width / 2, startY + height / 2, stopX + width / 2, stopY + height / 2, Ahorn.colors.selection_selected_fc, headLength=6)

        return true
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "touchSwitch"
        Ahorn.drawSprite(ctx, "objects/touchswitch/container.png", 0, 0)
        Ahorn.drawSprite(ctx, "objects/touchswitch/icon00.png", 0, 0)
        
        return true
    end
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
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