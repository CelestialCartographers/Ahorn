module DashSwitch

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict()

const textures = Dict{String, String}(
    "Temple A" => "default",
    "Temple B" => "mirror"
)

const directions = Dict{String, Tuple{Type, String, Bool}}(
    "up" => (Maple.DashSwitchVertical, "ceiling", false),
    "down" => (Maple.DashSwitchVertical, "ceiling", true),
    "left" => (Maple.DashSwitchHorizontal, "leftSide", false),
    "right" => (Maple.DashSwitchHorizontal, "leftSide", true),
)

const clockwiseDirections = String["up", "right", "down", "left"]

for (name, texture) in textures
    for (dir, data) in directions
        key = "Dash Switch ($(uppercasefirst(dir)), $(name))"
        func, datakey, val = data
        placements[key] = Ahorn.EntityPlacement(
            func,
            "rectangle",
            Dict{String, Any}(
                "sprite" => texture,
                datakey => val
            )
        )
    end
end

Ahorn.editingOptions(entity::Maple.DashSwitchHorizontal) = Dict{String, Any}(
    "sprite" => textures
)

Ahorn.editingOptions(entity::Maple.DashSwitchVertical) = Dict{String, Any}(
    "sprite" => textures
)

function Ahorn.selection(entity::Maple.DashSwitchHorizontal)
    x, y = Ahorn.position(entity)
    left = get(entity.data, "leftSide", false)

    if left
        return Ahorn.Rectangle(x, y - 1, 10, 16)

    else
        return Ahorn.Rectangle(x - 2, y - 1, 10, 16)
    end
end

function Ahorn.selection(entity::Maple.DashSwitchVertical)
    x, y = Ahorn.position(entity)
    ceiling = get(entity.data, "ceiling", false)

    if ceiling
        return Ahorn.Rectangle(x, y, 16, 12)

    else
        return Ahorn.Rectangle(x, y - 4, 16, 12)
    end
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.DashSwitchHorizontal, room::Maple.Room)
    sprite = get(entity.data, "sprite", "default")
    left = get(entity.data, "leftSide", false)
    texture = sprite == "default" ? "objects/temple/dashButton00.png" : "objects/temple/dashButtonMirror00.png"

    if left
        Ahorn.drawSprite(ctx, texture, 20, 25, rot=pi)

    else
        Ahorn.drawSprite(ctx, texture, 8, 7)
    end
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.DashSwitchVertical, room::Maple.Room)
    sprite = get(entity.data, "sprite", "default")
    ceiling = get(entity.data, "ceiling", false)
    texture = sprite == "default" ? "objects/temple/dashButton00.png" : "objects/temple/dashButtonMirror00.png"

    if ceiling
        Ahorn.drawSprite(ctx, texture, 9, 20, rot=-pi / 2)

    else
        Ahorn.drawSprite(ctx, texture, 27, 7, rot=pi / 2)
    end
end

function Ahorn.flipped(entity::Maple.DashSwitchHorizontal, horizontal::Bool)
    if horizontal
        entity.leftSide = !entity.leftSide

        return entity
    end
end

function Ahorn.flipped(entity::Maple.DashSwitchVertical, horizontal::Bool)
    if !horizontal
        entity.ceiling = !entity.ceiling

        return entity
    end
end

# TODO - Might need rotation offset
function Ahorn.rotated(entity::Maple.DashSwitchHorizontal, steps::Int)
    sideIndex = entity.leftSide ? 2 : 4
    targetIndex = mod1(sideIndex + steps, 4)

    if targetIndex != sideIndex
        side = clockwiseDirections[targetIndex]
        func, attr, value = directions[side]

        persistent = get(entity, "persistent", false)
        sprite = get(entity, "sprite", "default")

        return func(entity.x, entity.y, value, persistent, sprite)
    end
end

# TODO - Might need rotation offset
function Ahorn.rotated(entity::Maple.DashSwitchVertical, steps::Int)
    sideIndex = entity.ceiling ? 3 : 1
    targetIndex = mod1(sideIndex + steps, 4)

    if targetIndex != sideIndex
        side = clockwiseDirections[targetIndex]
        func, attr, value = directions[side]

        persistent = get(entity, "persistent", false)
        sprite = get(entity, "sprite", "default")

        return func(entity.x, entity.y, value, persistent, sprite)
    end
end

end