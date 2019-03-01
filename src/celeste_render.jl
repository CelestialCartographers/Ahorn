include("drawing.jl")
include("font.jl")
include("text_drawing.jl")
include("assets.jl")
include("layers.jl")
include("auto_tiler.jl")
include("decals.jl")
include("entities.jl")
include("triggers.jl")
include("fillers.jl")

function drawObjectTile(ctx::Cairo.CairoContext, x::Integer, y::Integer, tile::Integer; alpha::Number=getGlobalAlpha())
    scenery = getSprite("tilesets/scenery", "Gameplay")

    width = floor(Int, scenery.realWidth / 8)

    drawX, drawY = (x - 1) * 8, (y - 1) * 8
    quadY, quadX = divrem(tile, width)

    drawImage(ctx, "tilesets/scenery", drawX, drawY, quadX * 8, quadY * 8, 8, 8, alpha=alpha)
end

tileDrawPosition(x::Integer, y::Integer) = (x - 1) * 8, (y - 1) * 8

function getTileData(x::Integer, y::Integer, tiles::Tiles, meta::TilerMeta, states::TileStates)
    tileValue = tiles.data[y, x]

    if haskey(meta.paths, tileValue)
        imagePath = meta.paths[tileValue]
        quads, sprite = getMaskQuads(x, y, tiles, meta)

        return quads[Integer(mod1(states.rands[y, x], length(quads)))], sprite, imagePath
    end

    return nothing, nothing, nothing
end

function tileNeedsUpdate(tileValue::Char, x::Integer, y::Integer, quad::Tuple{Integer, Integer}, states::TileStates)
    return tileValue != states.chars[y, x] || states.quads[y, x] != quad
end

function drawTile(ctx::Cairo.CairoContext, x::Integer, y::Integer, tiles::Tiles, meta::TilerMeta, states::TileStates; alpha::Number=getGlobalAlpha())
    tileValue = tiles.data[y, x]
    drawX, drawY = tileDrawPosition(x, y)

    if tileValue != '0'
        quad, sprite, imagePath = getTileData(x, y, tiles, meta, states)
        
        if quad !== nothing
            quadX, quadY = quad

            if !isempty(sprite)
                animatedMeta = filter(m -> m.name == sprite, animatedTilesMeta)[1]
                frames = findTextureAnimations(animatedMeta.path, getAtlas("Gameplay"))

                if !isempty(frames)
                    frame = frames[Integer(mod1(states.rands[y, x], length(frames)))]
                    frameSprite = getSprite(frame, "Gameplay")

                    ox = animatedMeta.posX - frameSprite.offsetX
                    oy = animatedMeta.posY - frameSprite.offsetY

                    # TODO - What do we actually have to clear here?
                    #clearArea(ctx, drawX + ox, drawY + oy, 8, 8)
                    drawImage(ctx, frame, drawX + ox, drawY + oy, alpha=alpha)
                end
            end

            if tileNeedsUpdate(tileValue, x, y, quad, states)
                clearArea(ctx, drawX, drawY, 8, 8)
                drawImage(ctx, imagePath, drawX, drawY, quadX * 8, quadY * 8, 8, 8, alpha=alpha)

                states.quads[y, x] = quad
            end

        else
            drawRectangle(ctx, drawX, drawY, 8, 8, colors.unknown_tile_color, (0.0, 0.0, 0.0, 0.0))
        end
    
    else
        if states.chars[y, x] != '0'
            clearArea(ctx, drawX, drawY, 8, 8)
        end
    end

    states.chars[y, x] = tileValue
end

function drawTiles(ctx::Cairo.CairoContext, tiles::Tiles, objtiles::ObjectTiles, meta::TilerMeta, states::TileStates, width::Integer, height::Integer; alpha::Number=getGlobalAlpha(), fg::Bool=true, useObjectTiles::Bool=false)
    for y in 1:height, x in 1:width
        objtile = get(objtiles.data, (y, x), -1)
        tile = get(tiles.data, (y, x), '0')

        if useObjectTiles && objtile != -1 && tile != '0'
            drawObjectTile(ctx, x, y, objtile, alpha=alpha)

        else
            drawTile(ctx, x, y, tiles, meta, states, alpha=alpha)
        end
    end
end

function drawTiles(ctx::Cairo.CairoContext, dr::DrawableRoom, fg::Bool=true; alpha::Number=getGlobalAlpha(), useObjectTiles::Bool=false)
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

drawTiles(layer::Layer, dr::DrawableRoom, fg::Bool=true; alpha::Number=getGlobalAlpha(), useObjectTiles::Bool=false) = drawTiles(getSurfaceContext(layer.surface), dr, fg, alpha=alpha, useObjectTiles=useObjectTiles)

function drawParallax(ctx::Cairo.CairoContext, parallax::Maple.Parallax, camera::Camera, fg::Bool=true)

end

function drawApply(ctx::Cairo.CairoContext, apply::Maple.Apply, camera::Camera, fg::Bool=true)

end

function drawEffect(ctx::Cairo.CairoContext, effect::Maple.Effect, camera::Camera, fg::Bool=true)

end

backgroundFuncs = Dict{Type, Function}(
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

loadExternalSprites!()

drawingLayers = nothing
drawableRooms = Dict{Map, Dict{Room, DrawableRoom}}()

redrawingFuncs["fgDecals"] = (layer, room) -> drawDecals(layer, room, true)
redrawingFuncs["bgDecals"] = (layer, room) -> drawDecals(layer, room, false)

redrawingFuncs["fgTiles"] = (layer, room) -> drawTiles(layer, room, true)
redrawingFuncs["bgTiles"] = (layer, room) -> drawTiles(layer, room, false)

redrawingFuncs["fgParallax"] = (layer, room, camera) -> drawBackground(layer, room, camera, true)
redrawingFuncs["bgParallax"] = (layer, room, camera) -> drawBackground(layer, room, camera, false)

redrawingFuncs["entities"] = drawEntities
redrawingFuncs["triggers"] = drawTriggers

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
    width, height = floor(Int, ctx.surface.width), floor(Int, ctx.surface.height)

    paintSurface(ctx, backgroundFill)
    pattern_set_filter(get_source(ctx), Cairo.FILTER_NEAREST)

    for filler in map.fillers
        if fillerVisible(camera, width, height, filler)
            drawFiller(ctx, camera, filler)
        end
    end

    for room in map.rooms
        if roomVisible(camera, width, height, room)
            dr = getDrawableRoom(map, room)
            alpha = loadedState.roomName == room.name ? 1.0 : adjacentAlpha

            drawRoom(ctx, camera, dr, alpha=alpha)

        else
            if get(config, "delete_non_visible_rooms_cache", false)
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

function drawRoom(ctx::Cairo.CairoContext, camera::Camera, room::DrawableRoom; alpha::Number=getGlobalAlpha())
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