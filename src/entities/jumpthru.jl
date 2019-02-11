module JumpThru

using ..Ahorn, Maple

textures = ["wood", "dream", "temple", "templeB", "cliffside", "reflection", "core"]
const placements = Ahorn.PlacementDict(
    "Jump Through ($(uppercasefirst(texture)))" => Ahorn.EntityPlacement(
        Maple.JumpThru,
        "rectangle",
        Dict{String, Any}(
            "texture" => texture
        )
    ) for texture in textures
)

quads = Tuple{Integer, Integer, Integer, Integer}[
    (0, 0, 8, 7) (8, 0, 8, 7) (16, 0, 8, 7);
    (0, 8, 8, 5) (8, 8, 8, 5) (16, 8, 8, 5)
]

Ahorn.editingOptions(entity::Maple.JumpThru) = Dict{String, Any}(
    "texture" => textures
)

Ahorn.minimumSize(entity::Maple.JumpThru) = 8, 0
Ahorn.resizable(entity::Maple.JumpThru) = true, false

function Ahorn.selection(entity::Maple.JumpThru)
    x, y = Ahorn.position(entity)
    width = Int(get(entity.data, "width", 8))

    return Ahorn.Rectangle(x, y, width, 8)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.JumpThru, room::Maple.Room)
    texture = get(entity.data, "texture", "wood")
    texture = texture == "default" ? "wood" : texture

    # Values need to be system specific integer
    x = Int(get(entity.data, "x", 0))
    y = Int(get(entity.data, "y", 0))

    width = Int(get(entity.data, "width", 8))

    startX = div(x, 8) + 1
    stopX = startX + div(width, 8) - 1
    startY = div(y, 8) + 1

    len = stopX - startX
    for i in 0:len
        connected = false
        qx = 2
        if i == 0
            connected = get(room.fgTiles.data, (startY, startX - 1), false) != '0'
            qx = 1

        elseif i == len
            connected = get(room.fgTiles.data, (startY, stopX + 1), false) != '0'
            qx = 3
        end

        quad = quads[2 - connected, qx]
        Ahorn.drawImage(ctx, "objects/jumpthru/$(texture)", 8 * i, 0, quad...)
    end
end

end