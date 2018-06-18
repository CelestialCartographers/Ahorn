# Not the most efficient, but renders correctly
# exitBlock for some reason is named differently than its 4 other siblings
function drawTileEntity(ctx::Cairo.CairoContext, room::Maple.Room, entity::Maple.Entity; alpha::Number=getGlobalAlpha())
    x = Int(get(entity.data, "x", 0))
    y = Int(get(entity.data, "y", 0))

    blendIn = get(entity.data, "blendin", false)

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    tx, ty = floor(Int, x / 8) + 1, floor(Int, y / 8) + 1
    tw, th = floor(Int, width / 8), floor(Int, height / 8)

    ftw, fth = ceil.(Int, room.size ./ 8)

    key = entity.name == "exitBlock"? "tileType" : "tiletype"
    tile = get(entity.data, key, "3")
    tile = isa(tile, Number)? string(tile) : tile
    
    # Don't draw air versions, even though they shouldn't exist
    if tile != "0"
        fakeTiles = fill('0', (fth, ftw))

        if blendIn
            sliceY = max(ty - 1, 1):min(ty + th, fth)
            sliceX = max(tx - 1, 1):min(tx + tw, ftw)
            fakeTiles[sliceY, sliceX] = room.fgTiles.data[sliceY, sliceX]
        end

        fakeTiles[max(ty, 1):min(ty + th - 1, fth), max(tx, 1):min(tx + tw - 1, ftw)] = tile[1]

        dr = DrawableRoom(
            loadedState.map,
            Maple.Room(
                name=room.name,
                fgTiles=Maple.Tiles(fakeTiles)
            ),

            TileStates(),
            TileStates(),

            nothing,
            Layer[],

            colors.background_room_fill
        )
    end

    Cairo.save(ctx)

    rectangle(ctx, x, y, width, height)
    clip(ctx)
    drawTiles(ctx, dr, alpha=alpha)

    Cairo.restore(ctx)
end

function tileEntityFinalizer(entity::Maple.Entity)
    key = entity.name == "exitBlock"? "tileType" : "tiletype"
    defaultTile = string(Main.Maple.tile_fg_names["Snow"])
    tile = string(get(Main.persistence, "brushes_material_fgTiles", defaultTile))
    tile = tile == "0"? defaultTile : tile
    entity.data[key] = tile
end