module Bucket

displayName = "Bucket"
group = "Brushes"

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

        tiles = Main.roomTiles(targetLayer, room)
        drawFill(x, y, tiles, layer)
    end
end

function applyFill!(x::Number, y::Number, layer::Main.Layer, material::Char)
    tiles = layer.name == "fgTiles"? Main.loadedState.room.fgTiles : Main.loadedState.room.bgTiles

    Main.applyBrush!(bucketBrush, tiles, material, 1, 1)
end

function cleanup()
    global bucketPosition = nothing
    global bucketBrush = nothing

    Main.redrawLayer!(toolsLayer)
end

function setMaterials!(layer::Main.Layer, materials::Main.ListContainer)
    validTiles = Main.validTiles(layer)
    tileNames = Main.tileNames(layer)

    Main.updateTreeView!(materials, [tileNames[mat] for mat in validTiles], row -> row[1] == tileNames[material])
end

function toolSelected(subTools::Main.ListContainer, layers::Main.ListContainer, materials::Main.ListContainer)
    layerName = Main.layerName(targetLayer)
    tileNames = Main.tileNames(targetLayer)
    global material = get(Main.persistence, "brushes_$(layerName)_material", tileNames["Air"])[1]

    wantedLayer = get(Main.persistence, "brushes_layer", "fgTiles")
    Main.updateTreeView!(layers, ["fgTiles", "bgTiles"], row -> row[1] == wantedLayer)

    Main.redrawingFuncs["tools"] = drawBucket
    Main.redrawLayer!(toolsLayer)
end

function layerSelected(list::Main.ListContainer, materials::Main.ListContainer, selected::String)
    global targetLayer = Main.getLayerByName(drawingLayers, selected)
    Main.persistence["brushes_layer"] = selected

    tileNames = Main.tileNames(targetLayer)
    global material = get(Main.persistence, "brushes_material_$(selected)", tileNames["Air"])[1]
    setMaterials!(targetLayer, materials)
end

function materialSelected(list::Main.ListContainer, selected::String)
    tileNames = Main.tileNames(targetLayer)
    layerName = Main.layerName(targetLayer)
    Main.persistence["brushes_material_$(layerName)"] = tileNames[selected]
    global material = tileNames[selected]
end

function layersChanged(layers::Array{Main.Layer, 1})
    wantedLayer = get(Main.persistence, "brushes_layer", "fgTiles")

    global drawingLayers = layers
    global toolsLayer = Main.getLayerByName(layers, "tools")
    global targetLayer = Main.updateLayerList!(layers, wantedLayer, "fgTiles")
end

function mouseMotion(x::Number, y::Number)
    if bucketBrush === nothing || !get(bucketBrush.pixels, (y - bucketBrush.offset[2] + 1, x - bucketBrush.offset[1] + 1), false)
        global bucketPosition = (x, y)

        Main.redrawLayer!(toolsLayer)
    end
end

function middleClick(x::Number, y::Number)
    tiles = Main.roomTiles(targetLayer, Main.loadedState.room)
    tileNames = Main.tileNames(targetLayer)
    target = get(tiles.data, (y, x), '0')

    global material = target
    layerName = Main.layerName(targetLayer)
    Main.persistence["brushes_material_$(layerName)"] = material
    Main.selectMaterialList!(tileNames[target])
end

function leftClick(x::Number, y::Number)
    applyFill!(x, y, targetLayer, material)

    Main.redrawLayer!(targetLayer)
end

end