mutable struct TileStates
    quads::Array{Coord, 2}
    chars::Array{Char, 2}
    rands::Array{UInt8, 2}

    TileStates() = new(Matrix{Coord}(undef, 0, 0), Matrix{Char}(undef, 0, 0), Matrix{Int}(undef, 0, 0))
end

mutable struct DrawableRoom
    map::Map
    room::Room

    fgTileStates::TileStates
    bgTileStates::TileStates

    rendering::Union{Layer, Nothing}
    layers::Array{Layer, 1}

    fillColor::Union{Nothing, colorTupleType}
end

Base.size(state::TileStates) = size(state.rands)

getTileStateSeed(name::String, package::String="", fg::Bool=false) = foldl((a, b) -> a + Int(b) * 128, collect(package * (fg ? "fg" : "bg") * name), init=0)
getTileStateSeed(room::Room, package::String="", fg::Bool=false) = getTileStateSeed(room.name, package, fg)

const drawableRoomMersenneTwister = MersenneTwister()

function updateTileStates!(room::String, package::String, states::TileStates, width::Int, height::Int, fg::Bool=false)
    seed = getTileStateSeed(room, package, fg)
    Random.seed!(drawableRoomMersenneTwister, seed)

    states.quads = fill(Coord(-1, -1), (height, width))
    states.chars = fill('0', (height, width))
    states.rands = rand(drawableRoomMersenneTwister, 0:255, (height, width))
end

updateTileStates!(room::Room, package::String, states::TileStates, width::Int, height::Int, fg::Bool=false) = updateTileStates!(room.name, package, states, width, height, fg)

function getDrawingLayers()
    return Layer[
        Layer("bgParallax", dummy=true), # Not currently used, kept to keep order intact
        Layer("bgTiles", clearOnReset=false),
        Layer("bgDecals"),
        Layer("entities"),
        Layer("fgTiles", clearOnReset=false),
        Layer("fgParallax", dummy=true), # Not currently used, kept to keep order intact
        Layer("fgDecals"),
        Layer("triggers"),

        Layer("tools", selectable=false),
        Layer("all", dummy=true),
        Layer("objtiles", dummy=true)
    ]
end

function roomVisible(camera::Camera, width::Int, height::Int, room::Room)
    actuallX = camera.x / camera.scale
    actuallY = camera.y / camera.scale

    actuallWidth = width / camera.scale
    actuallHeight = height / camera.scale

    cameraRect = Rectangle(actuallX, actuallY, actuallWidth, actuallHeight)
    roomRect = Rectangle(room.position[1], room.position[2], room.size[1], room.size[2])

    return checkCollision(cameraRect, roomRect)
end

redrawRenderingLayer(renderingLayer::Layer, layers::Array{Layer, 1}) = renderingLayer.redraw || any(map(layer -> layer.redraw && !layer.dummy, layers))

function getRoomBackgroundColor(room::Room)::colorTupleType
    if 0 <= room.color < length(colors.background_room_color_coded_fill)
        return colors.background_room_color_coded_fill[room.color + 1]
        
    else
        return colors.background_room_fill
    end
end

function DrawableRoom(map::Map, room::Room)
    return DrawableRoom(
        map,
        room,

        TileStates(),
        TileStates(),

        Layer("rendering"),
        getDrawingLayers(),

        nothing
    )
end

function destroy(dr::DrawableRoom)
    deleteSurface(dr.rendering.surface)

    for layer in dr.layers
        deleteSurface(layer.surface)
    end
end