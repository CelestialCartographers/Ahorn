mutable struct TileStates
    quads::Array{Tuple{Integer, Integer}, 2}
    chars::Array{Char, 2}
    rands::Array{Integer, 2}

    TileStates() = new(Matrix{Tuple{Integer, Integer}}(0, 0), Matrix{Char}(0, 0), Matrix{Integer}(0, 0))
end

mutable struct DrawableRoom
    map::Map
    room::Room

    fgTileStates::TileStates
    bgTileStates::TileStates

    rendering::Union{Layer, Void}
    layers::Array{Layer, 1}
end

Base.size(state::TileStates) = size(state.rands)

getTileStateSeed(name::String, package::String="") = foldl((a, b) -> a + Int(b) * 128, 0, collect(package * name))
getTileStateSeed(room::Room, package::String="") = getTileStateSeed(room.name, package)

function updateTileStates!(room::String, package::String, states::TileStates, width::Integer, height::Integer)
    seed = getTileStateSeed(room, package)
    srand(seed)

    states.quads = fill((-1, -1), (height, width))
    states.chars = fill('0', (height, width))
    states.rands = rand(1:4, (height, width))
end

updateTileStates!(room::Room, package::String, states::TileStates, width::Integer, height::Integer) = updateTileStates!(room.name, package, states, width, height)

function getDrawingLayers()
    return Layer[
        Layer("bgParallax"),
        Layer("bgTiles"),
        Layer("bgDecals"),
        Layer("entities"),
        Layer("fgTiles"),
        Layer("fgParallax"),
        Layer("fgDecals"),
        Layer("triggers"),

        Layer("tools", selectable=false)
    ]
end

function roomVisible(camera::Camera, width::Integer, height::Integer, room::Room)
    actuallX = camera.x / camera.scale
    actuallY = camera.y / camera.scale

    actuallWidth = width / camera.scale
    actuallHeight = height / camera.scale

    cameraRect = Rectangle(actuallX, actuallY, actuallWidth, actuallHeight)
    roomRect = Rectangle(Int.(room.position)..., Int.(room.size)...)

    return checkCollision(cameraRect, roomRect)
end

redrawRenderingLayer(renderingLayer::Layer, layers::Array{Layer, 1}) = renderingLayer.redraw || any(map(layer -> layer.redraw, layers))

function DrawableRoom(map::Map, room::Room)
    return DrawableRoom(
        map,
        room,

        TileStates(),
        TileStates(),

        Layer("rendering"),
        getDrawingLayers()
    )
end