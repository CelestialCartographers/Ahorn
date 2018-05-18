module Bucket

displayName = "Bucket"

drawingLayers = Main.Layer[]

toolsLayer = nothing
targetLayer = nothing
material = '0'

bucketPosition = nothing
bucketBrush = nothing

function findFill(tiles::Array{Char, 2}, x::Number, y::Number)
    target = tiles[y, x]
    stack = Tuple{Number, Number}[(x, y)]

    h, w = size(tiles)

    res = fill(false, (h, w))

    while length(stack) > 0
        tx, ty = pop!(stack)

        if 1 <=tx <= w && 1 <= ty <= h && !res[ty, tx]
            if target == tiles[ty, tx]
                res[ty, tx] = true

                push!(stack, (tx - 1, ty))
                push!(stack, (tx, ty - 1))
                push!(stack, (tx + 1, ty))
                push!(stack, (tx, ty + 1))
            end
        end
    end

    return res
end

function drawFill(x::Number, y::Number, tiles::Main.Maple.Tiles, layer::Main.Layer)
    h, w = size(tiles.data)

    if 1 <=x <= w && 1 <= y <= h
        ctx = Main.creategc(layer.surface)

        pixels, ox, oy = Main.shrinkMatrix(findFill(tiles.data, x, y))
        global bucketBrush = Main.Brush("Bucket", pixels, (ox, oy))

        Main.drawBrush(bucketBrush, layer, 1, 1)
    end
end

function drawBucket(layer::Main.Layer, room::Main.Room)
    if bucketPosition != nothing
        x, y = bucketPosition

        tiles = Main.layerName(targetLayer) == "fgTiles"? Main.loadedRoom.fgTiles : Main.loadedRoom.bgTiles
        drawFill(x, y, tiles, layer)
    end
end

function applyFill!(x::Number, y::Number, layer::Main.Layer, material::Char)
    tiles = layer.name == "fgTiles"? Main.loadedRoom.fgTiles : Main.loadedRoom.bgTiles

    Main.applyBrush!(bucketBrush, tiles, material, 1, 1)
end

function cleanup()
    global bucketPosition = nothing

    Main.redrawLayer!(toolsLayer)
end

function setMaterials!(layer::Main.Layer, materials::Main.ListContainer)
    validTiles = layer.name == "fgTiles"? Main.Maple.valid_fg_tiles : Main.Maple.valid_bg_tiles

    Main.updateTreeView!(materials, [Main.Maple.tile_names[mat] for mat in validTiles], row -> row[1] == Main.Maple.tile_names[material])
end

function toolSelected(subTools::Main.ListContainer, layers::Main.ListContainer, materials::Main.ListContainer)
    Main.updateTreeView!(layers, ["fgTiles", "bgTiles"], row -> row[1] == Main.layerName(targetLayer))

    Main.redrawingFuncs["tools"] = drawBucket
    Main.redrawLayer!(toolsLayer)
end

function layerSelected(list::Main.ListContainer, materials::Main.ListContainer, selected::String)
    global targetLayer = Main.getLayerByName(Main.drawingLayers, selected)

    setMaterials!(targetLayer, materials)
end

function materialSelected(list::Main.ListContainer, selected::String)
    global material = Main.Maple.tile_names[selected]
end

function layersChanged(layers::Array{Main.Layer, 1})
    global drawingLayers = layers
    global toolsLayer = Main.getLayerByName(layers, "tools")
    global targetLayer = Main.updateLayerList!(layers, targetLayer, "fgTiles")
end

function mouseMotion(x::Number, y::Number)
    if bucketBrush === nothing || !get(bucketBrush.pixels, (y - bucketBrush.offset[2] + 1, x - bucketBrush.offset[1] + 1), false)
        global bucketPosition = (x, y)

        Main.redrawLayer!(toolsLayer)
    end
end

function middleClick(x::Number, y::Number)
    tiles = Main.layerName(targetLayer) == "fgTiles"? Main.loadedRoom.fgTiles : Main.loadedRoom.bgTiles
    target = get(tiles.data, (y, x), '0')

    global material = target
    Main.selectMaterialList!(Main.Maple.tile_names[target])
end

function leftClick(x::Number, y::Number)
    applyFill!(x, y, targetLayer, material)

    Main.redrawLayer!(targetLayer)
end

end