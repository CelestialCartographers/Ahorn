mutable struct TileStates
    quads::Array{Tuple{Integer, Integer}, 2}
    chars::Array{Char, 2}
    rands::Array{Integer, 2}

    TileStates() = new(Matrix{Tuple{Integer, Integer}}(undef, 0, 0), Matrix{Char}(undef, 0, 0), Matrix{Integer}(undef, 0, 0))
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

function updateTileStates!(room::String, package::String, states::TileStates, width::Integer, height::Integer, fg::Bool=false)
    seed = getTileStateSeed(room, package, fg)
    rng = MersenneTwister(seed)

    states.quads = fill((-1, -1), (height, width))
    states.chars = fill('0', (height, width))
    states.rands = rand(rng, 1:4, (height, width))
end

updateTileStates!(room::Room, package::String, states::TileStates, width::Integer, height::Integer, fg::Bool=false) = updateTileStates!(room.name, package, states, width, height, fg)

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

        Layer("tools", selectable=false),
        Layer("all", dummy=true)
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

function getRoomBackgroundColor(room::Room)
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
    ctx = getSurfaceContext(dr.rendering.surface)
    Cairo.destroy(ctx)

    for layer in dr.layers
        ctx = getSurfaceContext(layer.surface)
        Cairo.destroy(ctx)
    end
end