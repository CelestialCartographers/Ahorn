module Clutter

validClutterNames = String["yellowBlocks", "redBlocks", "greenBlocks"]
clutterDisplayNames = Dict{String, String}(
    "yellowBlocks" => "Boxes",
    "redBlocks" => "Laundry",
    "greenBlocks" => "Books"
)
clutterFunctions = Dict{String, Function}(
    "yellowBlocks" => Main.Maple.YellowBlock,
    "redBlocks" => Main.Maple.RedBlock,
    "greenBlocks" => Main.Maple.GreenBlock
)
simpleName = Dict{String, String}(
    "yellowBlocks" => "Yellow",
    "redBlocks" => "Red",
    "greenBlocks" => "Green"
)

placements = Dict{String, Main.EntityPlacement}(
    "Clutter Cabinet" => Main.EntityPlacement(
        Main.Maple.ClutterCabinet
    ),
)

for (raw, name) in clutterDisplayNames
    placements["Clutter Block ($name)"] = Main.EntityPlacement(
        clutterFunctions[raw],
        "rectangle"
    )

    placements["Clutter Switch ($name)"] = Main.EntityPlacement(
        Main.Maple.ColorSwitch,
        "point",
        Dict{String, Any}(
            "type" => simpleName[raw]
        )
    )

    placements["Clutter Door ($name)"] = Main.EntityPlacement(
        Main.Maple.ClutterDoor,
        "rectangle",
        Dict{String, Any}(
            "type" => simpleName[raw]
        )
    )
end

textureName(entity::Main.Maple.Entity, i::Integer) = "objects/resortclutter/$(lowercase(simpleName[entity.name]))_$(lpad(i, 2, "0"))"

function getTextures(entity::Main.Maple.Entity)
    i = 0
    res = Main.Sprite[]

    while haskey(Main.sprites, textureName(entity, i))
        push!(res, Main.sprites[textureName(entity, i)])
        i += 1
    end

    return res
end

function getEntityRng(entity::Main.Maple.Entity, dr::Main.DrawableRoom)
    x = floor(Int, get(entity.data, "x", 0) / 8)
    y = floor(Int, get(entity.data, "y", 0) / 8)

    width = floor(Int, get(entity.data, "width", 32) / 8)
    height = floor(Int, get(entity.data, "height", 32) / 8)

    randStates = dr.bgTileStates.rands
    rands = get(randStates, (y:y + height - 1, x:x + width - 1), 1)

    # Rands are stored as 1:4, we need 0:3 here
    seed = abs(foldl((n, m) -> n << 2 | m, rands .- 1))

    return MersenneTwister(seed)
end

function renderClutterBlock(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, dr::Main.DrawableRoom)
    entityX = Int(get(entity.data, "x", 0))
    entityY = Int(get(entity.data, "y", 0))

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    tw = ceil(Int, width / 8)
    th = ceil(Int, height / 8)

    needsDrawing = fill(true, (th, tw))

    rng = getEntityRng(entity, dr)
    textures = getTextures(entity)

    for y in 1:th, x in 1:tw
        if needsDrawing[y, x]
            choices = copy(textures)
            shuffle!(rng, choices)

            for choice in choices
                w, h = floor(Int, choice.width / 8), floor(Int, choice.height / 8)
                if all(get(needsDrawing, (y:y + h - 1, x:x + w - 1), false))
                    needsDrawing[y:y + h - 1, x:x + w - 1] = false
                    Main.drawImage(ctx, choice, entityX + x * 8 - 8, entityY + y * 8 - 8)

                    break
                end
            end
        end
    end
end

function editingOptions(entity::Main.Maple.Entity)
    if entity.name == "clutterDoor" || entity.name == "colorSwitch"
        return true, Dict{String, Any}(
            "type" => Main.Maple.clutter_block_colors
        )
    end
end

function minimumSize(entity::Main.Maple.Entity)
    if entity.name in validClutterNames
        return true, 8, 8

    elseif entity.name == "clutterDoor"
        return true, 16, 16
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name in validClutterNames
        return true, true, true
    
    elseif entity.name == "clutterDoor"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name in validClutterNames
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Main.Rectangle(x, y, width, height)

    elseif entity.name == "colorSwitch"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 4, y - 2, 40, 18)

    elseif entity.name == "clutterCabinet"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x, y, 16, 16)

    elseif entity.name == "clutterDoor"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Main.Rectangle(x, y, width, height)
    end
end

clutterDoorColor = (74, 71, 135, 0.6) ./ (255.0, 255.0, 255.0, 1.0)

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name in validClutterNames
        dr = Main.getDrawableRoom(Main.loadedState.map, room)

        renderClutterBlock(ctx, entity, dr)

        return true

    elseif entity.name == "colorSwitch"
        x, y = Main.entityTranslation(entity)

        variant = lowercase(get(entity.data, "type", "red"))
        sprite = Main.sprites["objects/resortclutter/icon_$variant"]

        Main.drawImage(ctx, "objects/resortclutter/clutter_button00", x - 4, y - 2)
        Main.drawImage(ctx, sprite, x + (32 - sprite.width) / 2, y + (16 - sprite.height) / 2)

        return true

    elseif entity.name == "clutterCabinet"
        x, y = Main.entityTranslation(entity)

        Main.drawImage(ctx, "objects/resortclutter/cabinet00", x, y)

        return true

    elseif entity.name == "clutterDoor"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 16))
        height = Int(get(entity.data, "height", 16))

        variant = lowercase(get(entity.data, "type", "red"))
        sprite = Main.sprites["objects/resortclutter/icon_$variant"]

        Main.drawRectangle(ctx, x, y, width, height, clutterDoorColor, (1.0, 1.0, 1.0, 8.0))
        Main.drawImage(ctx, sprite, x + width / 2 - (sprite.width) / 2, y + height / 2 - (sprite.height) / 2)

        return true
    end

    return false
end

end