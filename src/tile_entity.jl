function createFakeTiles(room::Maple.Room, x::Integer, y::Integer, width::Integer, height::Integer, material::Char='3'; blendIn::Bool=false)
    tx, ty = floor(Int, x / 8) + 1, floor(Int, y / 8) + 1
    tw, th = floor(Int, width / 8), floor(Int, height / 8)

    ftw, fth = ceil.(Int, room.size ./ 8)
    
    fakeTiles = fill('0', (th + 2, tw + 2))

    if blendIn
        
        fakeTiles[1:end, 1:end] = get(room.fgTiles.data, (ty - 1:ty + th, tx - 1:tx + tw), '0')
    end

    fakeTiles[2:end - 1, 2:end - 1] = material

    return fakeTiles
end

function materialTileTypeKey(entity::Maple.Entity)
    if entity.name == "exitBlock" || entity.name == "conditionBlock"
        return "tileType"

    else
        return "tiletype"
    end
end

# Not the most efficient, but renders correctly
function drawTileEntity(ctx::Cairo.CairoContext, room::Maple.Room, entity::Maple.Entity; material::Union{Char, Void}=nothing, alpha::Number=getGlobalAlpha(), blendIn::Bool=false)
    x = Int(get(entity.data, "x", 0))
    y = Int(get(entity.data, "y", 0))

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    blendIn = get(entity.data, "blendin", blendIn)

    if material === nothing
        key = materialTileTypeKey(entity)
        tile = get(entity.data, key, "3")
        material = isa(tile, Number)? string(tile) : tile
    end
    
    # Don't draw air versions, even though they shouldn't exist
    if material[1] in Maple.tile_entity_legal_tiles
        fakeTiles = createFakeTiles(room, x, y, width, height, material[1], blendIn=blendIn)
        drawFakeTiles(ctx, room, fakeTiles, true, x, y, alpha=alpha, clipEdges=true)
    end
end

function drawFakeTiles(ctx::Cairo.CairoContext, room::Maple.Room, tiles::Array{Char, 2}, fg::Bool, x::Number, y::Number; alpha::Number=getGlobalAlpha(), clipEdges::Bool=false)
    fakeDr = DrawableRoom(
        loadedState.map,
        Maple.Room(
            name="$(room.name)-$x-$y",
            fgTiles=Maple.Tiles(fg? tiles : Matrix{Char}(0, 0)),
            bgTiles=Maple.Tiles(!fg? tiles : Matrix{Char}(0, 0))
        ),

        TileStates(),
        TileStates(),

        nothing,
        Layer[],

        colors.background_room_fill
    )

    Cairo.save(ctx)

    if clipEdges
        height, width = (size(tiles) .- 2) .* 8
        rectangle(ctx, x, y, width, height)
        clip(ctx)

        # Offset the drawing since we trimmed away the border
        x -= 8
        y -= 8
    end

    translate(ctx, x, y)
    drawTiles(ctx, fakeDr, fg, alpha=alpha)

    Cairo.restore(ctx)
end

function tileEntityFinalizer(entity::Maple.Entity)
    key = materialTileTypeKey(entity)
    defaultTile = string(Maple.tile_fg_names["Snow"])
    tile = string(get(persistence, "brushes_material_fgTiles", defaultTile))
    tile = tile[1] in Maple.tile_entity_legal_tiles? tile : defaultTile
    entity.data[key] = tile
end