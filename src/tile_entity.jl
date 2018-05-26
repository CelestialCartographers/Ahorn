# Not the most efficient, but renders correctly
# exitBlock for some reason is named differently than its 4 other siblings
function drawTileEntity(ctx::Cairo.CairoContext, room::Maple.Room, entity::Maple.Entity; alpha::Number=getGlobalAlpha())
    x = Int(get(entity.data, "x", 0))
    y = Int(get(entity.data, "y", 0))

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    tx, ty = floor(Int, x / 8) + 1, floor(Int, y / 8) + 1
    tw, th = floor(Int, width / 8), floor(Int, height / 8)

    ftw, fth = ceil.(Int, room.size ./ 8)

    key = entity.name == "exitBlock"? "tileType" : "tiletype"
    tile = get(entity.data, key, "3")
    tile = isa(tile, Number)? string(tile) : tile
    
    fakeTiles = fill('0', (fth, ftw))
    fakeTiles[max(ty, 1):min(ty + th - 1, fth), max(tx, 1):min(tx + tw - 1, ftw)] = tile[1]

    dr = DrawableRoom(
        loadedMap,
        Maple.Room(
            name=room.name,
            fgTiles=Maple.Tiles(fakeTiles)
        ),

        TileStates(),
        TileStates(),

        nothing,
        Layer[]
    )

    drawTiles(ctx, dr, alpha=alpha)
end