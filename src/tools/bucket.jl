module Bucket

using ..Ahorn, Maple

displayName = "Bucket"
group = "Brushes"

drawingLayers = Ahorn.Layer[]

toolsLayer = nothing
targetLayer = nothing
material = '0'

bucketPosition = nothing
bucketBrush = nothing

function drawFill(x::Number, y::Number, tiles::Maple.Tiles, layer::Ahorn.Layer)
    h, w = size(tiles.data)

    if 1 <=x <= w && 1 <= y <= h
        pixels, ox, oy = Ahorn.shrinkMatrix(Ahorn.findFill(tiles.data, x, y))
        global bucketBrush = Ahorn.Brush("Bucket", pixels, (ox, oy))

        Ahorn.drawBrush(bucketBrush, layer, 1, 1)
    end
end

function drawBucket(layer::Ahorn.Layer, room::Ahorn.DrawableRoom, camera::Ahorn.Camera)
    if bucketPosition !== nothing
        x, y = bucketPosition
        tiles = Ahorn.roomTiles(targetLayer, room.room)

        drawFill(x, y, tiles, layer)
    end
end

function applyFill!(x::Number, y::Number, layer::Ahorn.Layer, material::Char)
    if bucketBrush !== nothing
        Ahorn.History.addSnapshot!(Ahorn.History.RoomSnapshot("Bucket ($material)", Ahorn.loadedState.room))

        Maple.updateTileSize!(Ahorn.loadedState.room, '0', '0')
        tiles = Ahorn.roomTiles(layer, Ahorn.loadedState.room)
        Ahorn.applyBrush!(bucketBrush, tiles, material, 1, 1)
    end
end

function cleanup()
    global bucketPosition = nothing
    global bucketBrush = nothing

    Ahorn.redrawLayer!(toolsLayer)
end

function setMaterials!(layer::Ahorn.Layer)
    Ahorn.loadXMLMeta()

    validTiles = Ahorn.validTiles(layer)
    tileNames = Ahorn.tileNames(layer)

    Ahorn.setMaterialList!([tileNames[mat] for mat in validTiles], row -> row[1] == get(tileNames, material, nothing))
end

function toolSelected(subTools::Ahorn.ListContainer, layers::Ahorn.ListContainer, materials::Ahorn.ListContainer)
    layerName = Ahorn.layerName(targetLayer)
    tileNames = Ahorn.tileNames(targetLayer)
    global material = get(Ahorn.persistence, "brushes_$(layerName)_material", tileNames["Air"])[1]

    wantedLayer = get(Ahorn.persistence, "brushes_layer", "fgTiles")
    Ahorn.updateLayerList!(["fgTiles", "bgTiles"], row -> row[1] == wantedLayer)

    Ahorn.redrawingFuncs["tools"] = drawBucket
    Ahorn.redrawLayer!(toolsLayer)
end

function layerSelected(list::Ahorn.ListContainer, materials::Ahorn.ListContainer, selected::String)
    global targetLayer = Ahorn.getLayerByName(drawingLayers, selected)
    Ahorn.persistence["brushes_layer"] = selected

    tileNames = Ahorn.tileNames(targetLayer)
    global material = get(Ahorn.persistence, "brushes_material_$(selected)", tileNames["Air"])[1]
    setMaterials!(targetLayer)
end

function materialSelected(list::Ahorn.ListContainer, selected::String)
    tileNames = Ahorn.tileNames(targetLayer)
    layerName = Ahorn.layerName(targetLayer)
    Ahorn.persistence["brushes_material_$(layerName)"] = tileNames[selected]
    global material = tileNames[selected]
end

function materialFiltered(list::Ahorn.ListContainer)
    tileNames = Ahorn.tileNames(targetLayer)
    Ahorn.selectRow!(list, row -> row[1] == get(tileNames, material, '0'))
end

function layersChanged(layers::Array{Ahorn.Layer, 1})
    wantedLayer = get(Ahorn.persistence, "brushes_layer", "fgTiles")

    global drawingLayers = layers
    global toolsLayer = Ahorn.getLayerByName(layers, "tools")
    global targetLayer = Ahorn.selectLayer!(layers, wantedLayer, "fgTiles")
end

function mouseMotion(x::Number, y::Number)
    tiles = Ahorn.roomTiles(targetLayer, Ahorn.loadedState.room)
    h, w = size(tiles.data)

    if bucketBrush === nothing || !get(bucketBrush.pixels, (y - bucketBrush.offset[2] + 1, x - bucketBrush.offset[1] + 1), false)
        global bucketPosition = (x, y)

        Ahorn.redrawLayer!(toolsLayer)
    end

    if x < 1 || x > w || y < 1 || y > h
        global bucketBrush = nothing
    end
end

function middleClick(x::Number, y::Number)
    tiles = Ahorn.roomTiles(targetLayer, Ahorn.loadedState.room)
    tileNames = Ahorn.tileNames(targetLayer)
    target = get(tiles.data, (y, x), '0')

    global material = target
    layerName = Ahorn.layerName(targetLayer)
    Ahorn.persistence["brushes_material_$(layerName)"] = material
    Ahorn.selectMaterialList!(tileNames[target])
end

function leftClick(x::Number, y::Number)
    applyFill!(x, y, targetLayer, material)

    Ahorn.redrawLayer!(targetLayer)
end

end