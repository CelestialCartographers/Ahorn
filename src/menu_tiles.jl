fgtile_menu_previews = Dict{Char, Cairo.CairoSurface}()
bgtile_menu_previews = Dict{Char, Cairo.CairoSurface}()

previewStates = TileStates()
updateTileStates!("preview", "preview", previewStates, 5, 5)

function generatePreview(surface::CairoSurface, tiles::Maple.Tiles, states::TileStates, fg::Bool=true)
    ctx = creategc(surface)
    height, width = size(tiles.data)

    meta = fg? fgTilerMeta : bgTilerMeta

    for y in 1:height, x in 1:width
        drawTile(ctx, x, y, tiles, meta, states)
    end

    return surface
end

for c in Maple.valid_fg_tiles
    tiles = fill('0', (5, 5))
    tiles[2:end - 1, 2:end - 1] = c

    fgtile_menu_previews[c] = generatePreview(Cairo.CairoARGBSurface(40, 40), Tiles(tiles), previewStates, true)
end

for c in Maple.valid_bg_tiles
    tiles = fill('0', (5, 5))
    tiles[2:end - 1, 2:end - 1] = c

    bgtile_menu_previews[c] = generatePreview(Cairo.CairoARGBSurface(40, 40), Tiles(tiles), previewStates, false)
end

