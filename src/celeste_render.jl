include("assets.jl")
include("drawing.jl")
include("font.jl")
include("text_drawing.jl")
include("auto_tiler.jl")
include("layers.jl")
include("decals.jl")
include("entities.jl")
include("triggers.jl")
include("fillers.jl")
include("helpers/tileset_splitter.jl")

struct TileData
    coord::Coord
    sprites::Array{String, 1}
    path::String
end

const unusedQuad = Coord(-1, -1)

function drawObjectTile(ctx::Cairo.CairoContext, x::Int, y::Int, tile::Int; alpha=nothing)
    scenery = getSprite("tilesets/scenery", "Gameplay")

    width = floor(Int, scenery.realWidth / 8)

    drawX, drawY = (x - 1) * 8, (y - 1) * 8
    quadY, quadX = divrem(tile, width)

    drawImage(ctx, "tilesets/scenery", drawX, drawY, quadX * 8, quadY * 8, 8, 8, alpha=alpha)
end

function getTileData(x::Int, y::Int, tiles::Tiles, meta::TilerMeta, states::TileStates)::Union{Nothing, TileData}
    tileValue::Char = tiles.data[y, x]

    if haskey(meta.paths, tileValue)
        imagePath::String = meta.paths[tileValue]
        quads::Array{Coord, 1}, sprites::Array{String, 1} = getMaskQuads(x, y, tiles, meta)
        targetQuad::Coord = quads[Int(mod1(states.rands[y, x], length(quads)))]

        return TileData(targetQuad, sprites, imagePath)
    end

    return nothing
end

function tileNeedsUpdate(tileValue::Char, x::Int, y::Int, quad::Coord, states::TileStates)
    return tileValue != states.chars[y, x] || states.quads[y, x] != quad
end

function getTile(tiles, x, y, width, height, default)
    if 1 <= x <= width && 1 <= y <= height
        return @inbounds tiles.data[y, x]

    else
        return default
    end
end

function getTilesInformation(tiles, meta)
    exists = Dict{Char, Bool}()
    sprites = Dict{Char, Sprite}()
    matricies = Dict{Char, Array{Sprite, 2}}()

    for tile in tiles
        if haskey(meta.paths, tile)
            imagePath = meta.paths[tile]
            sprite = getSprite(imagePath, "Gameplay")

            exists[tile] = imagePath != "" && sprite.surface !== Ahorn.Assets.missingImage
            sprites[tile] = sprite
            matricies[tile] = TilesetSplitter.getTilesetSpriteMatrix(sprite, 8, 8)
        end
    end

    return exists, sprites, matricies
end

# TODO - Consider caching findTextureAnimations, not called often
function drawTile(ctx::Cairo.CairoContext, x, y, tile, tiles, meta, states, existingPaths, spriteLookup, spriteMatricies; alpha=nothing)
    drawX = (x - 1) * 8
    drawY = (y - 1) * 8

    if tile != '0'
        tileData = getTileData(x, y, tiles, meta, states)

        if tileData !== nothing
            quad, sprites = tileData.coord, tileData.sprites
            imagePathExists = existingPaths[tile]

            if imagePathExists
                quadX, quadY = quad.x, quad.y

                if !isempty(sprites)
                    animatedMetas = filter(m -> m.name in sprites, animatedTilesMeta)

                    if !isempty(animatedMetas)
                        animatedMeta = animatedMetas[Int(mod1(states.rands[y, x], length(animatedMetas)))]
                        frames = findTextureAnimations(animatedMeta.path, getAtlas("Gameplay"))

                        if !isempty(frames)
                            frame = frames[Int(mod1(states.rands[y, x], length(frames)))]
                            frameSprite = getSprite(frame, "Gameplay")

                            ox = animatedMeta.posX - frameSprite.offsetX
                            oy = animatedMeta.posY - frameSprite.offsetY

                            # TODO - What do we actually have to clear here?
                            #clearArea(ctx, drawX + ox, drawY + oy, 8, 8)
                            drawImage(ctx, frame, drawX + ox, drawY + oy, alpha=alpha)
                        end
                    end
                end

                if tileNeedsUpdate(tile, x, y, quad, states)
                    if states.quads[y, x] != unusedQuad
                        clearArea(ctx, drawX, drawY, 8, 8)
                    end

                    drawImage(ctx, spriteMatricies[tile][quadY + 1, quadX + 1], drawX, drawY, 0, 0, 8, 8, alpha=alpha, guaranteedNoClip=true)

                    states.quads[y, x] = quad
                end

            else
                drawRectangle(ctx, drawX, drawY, 8, 8, colors.unknown_tile_color, (0.0, 0.0, 0.0, 0.0))
            end
        end

    else
        if states.chars[y, x] != '0' && states.quads[y, x] != unusedQuad
            clearArea(ctx, drawX, drawY, 8, 8)
        end
    end

    states.chars[y, x] = tile
end

function drawTiles(ctx::Cairo.CairoContext, tiles::Tiles, objtiles::ObjectTiles, meta::TilerMeta, states::TileStates, width, height; alpha=nothing, fg::Bool=true, useObjectTiles::Bool=false)
    existingPaths, spriteLookup, spriteMatricies = getTilesInformation(unique(tiles.data), meta)
    objHeight, objWidth = size(objtiles.data)

    for y in 1:height, x in 1:width
        tile = getTile(tiles, x, y, width, height, '0')

        if useObjectTiles && fg && tile != '0'
            objtile = getTile(objtiles, x, y, objWidth, objHeight, -1)

            if objtile != -1
                drawObjectTile(ctx, x, y, objtile, alpha=alpha)

            else
                drawTile(ctx, x, y, tile, tiles, meta, states, existingPaths, spriteLookup, spriteMatricies, alpha=alpha)
            end

        else
            drawTile(ctx, x, y, tile, tiles, meta, states, existingPaths, spriteLookup, spriteMatricies, alpha=alpha)
        end
    end
end

function drawTiles(ctx::Cairo.CairoContext, dr::DrawableRoom, fg::Bool=true; alpha=nothing, useObjectTiles::Bool=false)
    objtiles = dr.room.objTiles
    tiles = fg ? dr.room.fgTiles : dr.room.bgTiles
    height, width = size(tiles.data)

    states = fg ? dr.fgTileStates : dr.bgTileStates
    meta = fg ? fgTilerMeta : bgTilerMeta

    if size(states) != (height, width)
        updateTileStates!(dr.room, dr.map.package, states, width, height, fg)
    end

    drawTiles(ctx, tiles, objtiles, meta, states, width, height, alpha=alpha, fg=fg, useObjectTiles=useObjectTiles)

    return true
end

function drawTiles(layer::Layer, dr::DrawableRoom, fg::Bool=true; alpha=nothing, useObjectTiles::Bool=false)
    ctx = getSurfaceContext(layer.surface)

    drawTiles(ctx, dr, fg, alpha=alpha, useObjectTiles=useObjectTiles)
end

function drawParallax(ctx::Cairo.CairoContext, parallax::Maple.Parallax, camera::Camera, fg::Bool=true)

end

function drawApply(ctx::Cairo.CairoContext, apply::Maple.Apply, camera::Camera, fg::Bool=true)

end

function drawEffect(ctx::Cairo.CairoContext, effect::Maple.Effect, camera::Camera, fg::Bool=true)

end

const backgroundFuncs = Dict{Type, Function}(
    Maple.Parallax => drawParallax,
    Maple.Apply => drawApply,
    Maple.Effect => drawEffect,
)

function drawBackground(layer::Layer, dr::DrawableRoom, camera::Camera, fg::Bool=true)
    backdrops = fg ? dr.map.style.foregrounds : dr.map.style.backgrounds
    ctx = getSurfaceContext(layer.surface)

    if !fg
        color = something(dr.fillColor, getRoomBackgroundColor(dr.room))
        paintSurface(ctx, color)
    end

    for backdrop in backdrops
        t = typeof(backdrop)

        if haskey(backgroundFuncs, t)
            backgroundFuncs[t](ctx, backdrop, camera, fg)
        end
    end
end

function drawDecals(layer::Layer, dr::DrawableRoom, fg::Bool=true)
    ctx = getSurfaceContext(layer.surface)
    decals = fg ? dr.room.fgDecals : dr.room.bgDecals

    for decal in decals
        drawDecal(ctx, decal)
    end

    return true
end

function drawEntities(layer::Layer, dr::DrawableRoom)
    ctx = getSurfaceContext(layer.surface)
    entities = dr.room.entities
    
    for entity in entities
        renderEntity(ctx, layer, entity, dr.room)
    end

    return true
end

function drawTriggers(layer::Layer, dr::DrawableRoom)
    ctx = getSurfaceContext(layer.surface)
    triggers = dr.room.triggers
    
    for trigger in triggers
        renderTrigger(ctx, layer, trigger, dr.room)
    end

    return true
end

function resetDrawingSettings()
    reset!(camera)
end

drawingLayers = nothing

const drawableRooms = Dict{Map, Dict{Room, DrawableRoom}}()

redrawingFuncs["fgDecals"] = (layer, room, camera) -> drawDecals(layer, room, true)
redrawingFuncs["bgDecals"] = (layer, room, camera) -> drawDecals(layer, room, false)

redrawingFuncs["fgTiles"] = (layer, room, camera) -> drawTiles(layer, room, true)
redrawingFuncs["bgTiles"] = (layer, room, camera) -> drawTiles(layer, room, false)

redrawingFuncs["fgParallax"] = (layer, room, camera) -> drawBackground(layer, room, camera, true)
redrawingFuncs["bgParallax"] = (layer, room, camera) -> drawBackground(layer, room, camera, false)

redrawingFuncs["entities"] = (layer, room, camera) -> drawEntities(layer, room)
redrawingFuncs["triggers"] = (layer, room, camera) -> drawTriggers(layer, room)

function getDrawableRooms(map::Map)
    if !haskey(drawableRooms, map)
        drawableRooms[map] = Dict{Room, DrawableRoom}()
    end

    return collect(values(drawableRooms[map]))
end

function getDrawableRoom(map::Map, room::Room)
    if !haskey(drawableRooms, map)
        drawableRooms[map] = Dict{Room, DrawableRoom}()
    end

    if !haskey(drawableRooms[map], room)
        drawableRooms[map][room] = DrawableRoom(map, room)
    end

    return drawableRooms[map][room]
end

function deleteDrawableRoomCache(map::Map)
    rooms = getDrawableRooms(map)
    for room in rooms
        destroy(room)
    end

    delete!(drawableRooms, map)
end

function updateDrawingLayers!(map::Map, room::Room)
    global drawingLayers = getDrawableRoom(map, room).layers
end

function drawMap(ctx::Cairo.CairoContext, camera::Camera, map::Map; adjacentAlpha::Number=colors.adjacent_room_alpha, backgroundFill::colorTupleType=colors.background_canvas_fill)
    deleteNonVisibleRooms = get(config, "delete_non_visible_rooms_cache", false)
    width, height = floor(Int, ctx.surface.width), floor(Int, ctx.surface.height)

    paintSurface(ctx, backgroundFill)
    pattern_set_filter(get_source(ctx), Cairo.FILTER_NEAREST)

    for filler in map.fillers
        if fillerVisible(camera, width, height, filler)
            drawFiller(ctx, camera, filler)
        end
    end

    for room in map.rooms
        visible = roomVisible(camera, width, height, room)

        if visible
            dr = getDrawableRoom(map, room)
            alpha = loadedState.roomName == room.name ? 1.0 : adjacentAlpha

            drawRoom(ctx, camera, dr, alpha=alpha)

        else
            if deleteNonVisibleRooms
                if haskey(drawableRooms, map)
                    if haskey(drawableRooms[map], room)
                        destroy(drawableRooms[map][room])
                        delete!(drawableRooms[map], room)
                    end
                end
            end
        end
    end
end

drawMap(canvas::Gtk.GtkCanvas, camera::Camera, map::Map) = drawMap(Gtk.getgc(canvas), camera, map)

function drawRoom(ctx::Cairo.CairoContext, camera::Camera, room::DrawableRoom; alpha=nothing)
    renderingLayer = room.rendering
    drawingLayers = room.layers

    renderingLayer.redraw = redrawRenderingLayer(renderingLayer, drawingLayers)

    if renderingLayer.redraw
        resetLayer!(renderingLayer, room)
        renderingCtx = getSurfaceContext(renderingLayer.surface)

        renderingLayer.redraw = false
        combineLayers!(renderingCtx, drawingLayers, camera, room)
    end

    Cairo.save(ctx)

    translate(ctx, -camera.x, -camera.y)
    scale(ctx, camera.scale, camera.scale)
    translate(ctx, room.room.position...)

    applyLayer!(ctx, renderingLayer, alpha=alpha)

    restore(ctx)
end