module Clutter

using ..Ahorn, Maple
using Random

const validClutterNames = String["yellowBlocks", "redBlocks", "greenBlocks"]
const clutterDisplayNames = Dict{String, String}(
    "yellowBlocks" => "Boxes",
    "redBlocks" => "Laundry",
    "greenBlocks" => "Books"
)
const clutterFunctions = Dict{String, Type}(
    "yellowBlocks" => Maple.YellowBlock,
    "redBlocks" => Maple.RedBlock,
    "greenBlocks" => Maple.GreenBlock
)
const simpleName = Dict{String, String}(
    "yellowBlocks" => "Yellow",
    "redBlocks" => "Red",
    "greenBlocks" => "Green"
)
const clutterBlockUnion = Union{
    Maple.YellowBlock,
    Maple.RedBlock,
    Maple.GreenBlock
}

const placements = Ahorn.PlacementDict(
    "Clutter Cabinet" => Ahorn.EntityPlacement(
        Maple.ClutterCabinet
    ),
)

for (raw, name) in clutterDisplayNames
    placements["Clutter Block ($name)"] = Ahorn.EntityPlacement(
        clutterFunctions[raw],
        "rectangle"
    )

    placements["Clutter Switch ($name)"] = Ahorn.EntityPlacement(
        Maple.ColorSwitch,
        "point",
        Dict{String, Any}(
            "type" => simpleName[raw]
        )
    )

    placements["Clutter Door ($name)"] = Ahorn.EntityPlacement(
        Maple.ClutterDoor,
        "point",
        Dict{String, Any}(
            "type" => simpleName[raw]
        )
    )
end

textureName(entity::clutterBlockUnion, i::Integer) = "objects/resortclutter/$(lowercase(simpleName[entity.name]))_$(lpad(i, 2, "0"))"

function getTextures(entity::clutterBlockUnion)
    i = 0
    res = Ahorn.Sprite[]

    atlas = Ahorn.getAtlas("Gameplay")

    while haskey(atlas, textureName(entity, i))
        push!(res, Ahorn.getSprite(textureName(entity, i), "Gameplay"))
        i += 1
    end

    return res
end

function getEntityRng(entity::clutterBlockUnion, dr::Ahorn.DrawableRoom)
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

function renderClutterBlock(ctx::Ahorn.Cairo.CairoContext, entity::clutterBlockUnion, dr::Ahorn.DrawableRoom)
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
                    needsDrawing[y:y + h - 1, x:x + w - 1] .= false
                    Ahorn.drawImage(ctx, choice, entityX + x * 8 - 8, entityY + y * 8 - 8)

                    break
                end
            end
        end
    end
end

Ahorn.editingOptions(entity::Maple.ClutterDoor) = Dict{String, Any}(
    "type" => Maple.clutter_block_colors
)
Ahorn.editingOptions(entity::Maple.ColorSwitch) = Dict{String, Any}(
    "type" => Maple.clutter_block_colors
)

Ahorn.minimumSize(entity::clutterBlockUnion) = 8, 8
Ahorn.resizable(entity::clutterBlockUnion) = true, true

Ahorn.selection(entity::clutterBlockUnion) = Ahorn.getEntityRectangle(entity)

function Ahorn.selection(entity::Maple.ColorSwitch)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - 4, y - 2, 40, 18)
end

function Ahorn.selection(entity::Maple.ClutterCabinet)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x, y, 16, 16)
end

function Ahorn.selection(entity::Maple.ClutterDoor)
    x, y = Ahorn.position(entity)

    width = Int(get(entity.data, "width", 24))
    height = Int(get(entity.data, "height", 24))

    return Ahorn.Rectangle(x, y, width, height)
end

clutterDoorColor = (74, 71, 135, 0.6) ./ (255.0, 255.0, 255.0, 1.0)

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::clutterBlockUnion, room::Maple.Room)
    dr = Ahorn.getDrawableRoom(Ahorn.loadedState.map, room)

    renderClutterBlock(ctx, entity, dr)
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::ColorSwitch, room::Maple.Room)
    x, y = Ahorn.position(entity)

    variant = lowercase(get(entity.data, "type", "red"))
    sprite = Ahorn.getSprite("objects/resortclutter/icon_$variant", "Gameplay")

    Ahorn.drawImage(ctx, "objects/resortclutter/clutter_button00", x - 4, y - 2)
    Ahorn.drawImage(ctx, sprite, x + (32 - sprite.width) / 2, y + (16 - sprite.height) / 2)
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::ClutterCabinet, room::Maple.Room)
    x, y = Ahorn.position(entity)

    Ahorn.drawImage(ctx, "objects/resortclutter/cabinet00", x, y)
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::ClutterDoor, room::Maple.Room)
    x, y = Ahorn.position(entity)

    width = Int(get(entity.data, "width", 24))
    height = Int(get(entity.data, "height", 24))

    variant = lowercase(get(entity.data, "type", "red"))
    sprite = Ahorn.getSprite("objects/resortclutter/icon_$variant", "Gameplay")

    Ahorn.drawRectangle(ctx, x, y, width, height, clutterDoorColor, (1.0, 1.0, 1.0, 8.0))
    Ahorn.drawImage(ctx, sprite, x + width / 2 - (sprite.width) / 2, y + height / 2 - (sprite.height) / 2)
end

end