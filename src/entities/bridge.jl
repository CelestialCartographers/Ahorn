module Bridge

using ..Ahorn, Maple

function bridgeFinalizer(entity::Maple.Bridge)
    x, y = Ahorn.position(entity)

    entity.data["nodes"] = [
        (x + 96, y),
        (x + 128, y),
    ]
end

const placements = Ahorn.PlacementDict(
    "Bridge" => Ahorn.EntityPlacement(
        Maple.Bridge,
        "rectangle",
        Dict{String, Any}(),
        bridgeFinalizer
    ),
    "Bridge (Fixed)" => Ahorn.EntityPlacement(
        Maple.BridgeFixed,
        "rectangle"
    )
)

bridgeSprite = "scenery/bridge"
bridgeFixedSprite = "scenery/bridge_fixed"

Ahorn.minimumSize(entity::Maple.Bridge) = 32, 0
Ahorn.minimumSize(entity::Maple.BridgeFixed) = Ahorn.getSprite(bridgeFixedSprite, "Gameplay").width, 0

Ahorn.resizable(entity::Maple.Bridge) = true, false
Ahorn.resizable(entity::Maple.BridgeFixed) = true, false

Ahorn.nodeLimits(entity::Maple.Bridge) = 2, 2

function Ahorn.selection(entity::Maple.Bridge)
    x, y = Ahorn.position(entity)
    
    sprite = Ahorn.getSprite(bridgeSprite, "Gameplay")
    nodes = get(entity.data, "nodes", ())

    if length(nodes) == 2
        gapStartX = nodes[1][1]
        gapEndX = nodes[2][1]

        return [
            Ahorn.Rectangle(x, y - 3, bridgeSelectionWidth(entity), sprite.height),
            Ahorn.Rectangle(gapStartX - 4, y - 16, 8, 32),
            Ahorn.Rectangle(gapEndX - 4, y - 16, 8, 32)
        ]
    end
end

function Ahorn.selection(entity::Maple.BridgeFixed)
    x, y = Ahorn.position(entity)

    sprite = Ahorn.getSprite(bridgeFixedSprite, "Gameplay")
    width = get(entity.data, "width", 32)

    selectionWidth = ceil(Int, (width / sprite.width)) * sprite.width

    return Ahorn.Rectangle(x, y - 4, selectionWidth, sprite.height)
end

sizes = Ahorn.Rectangle[
    Ahorn.Rectangle(0, 0, 16, 52),
    Ahorn.Rectangle(16, 0, 8, 52),
    Ahorn.Rectangle(24, 0, 8, 52),
    Ahorn.Rectangle(32, 0, 8, 52),
    Ahorn.Rectangle(40, 0, 8, 52),
    Ahorn.Rectangle(48, 0, 8, 52),
    Ahorn.Rectangle(56, 0, 8, 52),
    Ahorn.Rectangle(64, 0, 8, 52),
    Ahorn.Rectangle(72, 0, 8, 52),
    Ahorn.Rectangle(80, 0, 16, 52),
    Ahorn.Rectangle(96, 0, 8, 52)
]

function renderBridgeTile(ctx::Ahorn.Cairo.CairoContext, x::Integer, y::Integer, size::Ahorn.Rectangle)
    tileWidth = size.w
    tileHeight = size.h

    if tileWidth == 16
        height = 24
        py = 0

        while py < tileHeight
            Ahorn.drawImage(ctx, bridgeSprite, x, y + py - 3, size.x, py, tileWidth, height)

            py += height
            height = 12
        end

    else
        Ahorn.drawImage(ctx, bridgeSprite, x, y - 3, size.x, size.y, tileWidth, tileHeight)
    end
end

# Helper for selections
function bridgeSelectionWidth(entity::Maple.Bridge)
    x, y = Ahorn.position(entity)

    width = get(entity.data, "width", 32)
    nodes = get(entity.data, "nodes", ())

    if length(nodes) == 2
        rng = Ahorn.getSimpleEntityRng(entity)

        gapStartX = nodes[1][1]
        gapEndX = nodes[2][1]

        index = 1
        px, py = x, y

        while px < x + width
            tileSize = index < 3 || index > 8 ? sizes[index] : sizes[3 + rand(rng, 0:6)]

            px += tileSize.w
            index = mod1(index + 1, length(sizes))
        end
    end

    return px - x
end

function renderBridge(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Bridge)
    x, y = Ahorn.position(entity)

    width = get(entity.data, "width", 32)
    nodes = get(entity.data, "nodes", ())

    if length(nodes) == 2
        rng = Ahorn.getSimpleEntityRng(entity)

        gapStartX = nodes[1][1]
        gapEndX = nodes[2][1]

        index = 1
        px, py = x, y

        while px < x + width
            tileSize = index < 3 || index > 8 ? sizes[index] : sizes[3 + rand(rng, 0:6)]

            if px < gapStartX || px >= gapEndX
                renderBridgeTile(ctx, px, py, tileSize)
            end

            px += tileSize.w
            index = mod1(index + 1, length(sizes))
        end
    end
end

function renderFixedBridge(ctx::Ahorn.Cairo.CairoContext, entity::Maple.BridgeFixed)
    x, y = Ahorn.position(entity)

    width = get(entity.data, "width", 32)

    px = x
    sprite = Ahorn.getSprite(bridgeFixedSprite, "Gameplay")

    while px < x + width
        Ahorn.drawSprite(ctx, bridgeFixedSprite, px, y - 8, jx=0.0, jy=0.0)

        px += sprite.width
    end
end

Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Bridge, room::Maple.Room) = renderBridge(ctx, entity)
Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.BridgeFixed, room::Maple.Room) = renderFixedBridge(ctx, entity)

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Bridge, room::Maple.Room)
    x, y = Ahorn.position(entity)
    nodes = get(entity.data, "nodes", ())

    width = Int(get(entity.data, "width", 8))

    if length(nodes) == 2
        gapStartX = nodes[1][1]
        gapEndX = nodes[2][1]

        Ahorn.drawRectangle(ctx, gapStartX, y - 16, 1, 32, (1.0, 0.0, 0.0, 1.0), (0.0, 0.0, 0.0, 0.0))
        Ahorn.drawRectangle(ctx, gapEndX, y - 16, 1, 32, (1.0, 0.0, 0.0, 1.0), (0.0, 0.0, 0.0, 0.0))
    end
end

end