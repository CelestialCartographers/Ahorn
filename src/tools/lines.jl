module Lines

displayName = "Lines"
group = "Brushes"

drawingLayers = Main.Layer[]

toolsLayer = nothing
targetLayer = nothing
material = '0'

line = nothing
lineBrush = nothing

function drawLine(line::Main.Line, layer::Main.Layer)
    ctx = Main.creategc(layer.surface)

    points = Main.pointsOnLine(line)
    pixels, ox, oy = Main.nodesToBrushPixels(points)
    global lineBrush = Main.Brush("Line", pixels, (ox, oy))

    Main.drawBrush(lineBrush, layer, 1, 1)
end

function drawLines(layer::Main.Layer, room::Main.Room)
    if line != nothing
        drawLine(line, toolsLayer)
    end
end

function applyLine!(line::Main.Line, tiles::Main.Maple.Tiles, material::Char)
    layer = Main.layerName(targetLayer)
    Main.History.addSnapshot!(Main.History.RoomSnapshot("Line $(material)", Main.loadedState.room))

    Main.applyBrush!(lineBrush, tiles, material, 1, 1)
end

function cleanup()
    global line = nothing

    Main.redrawLayer!(toolsLayer)
end

function setMaterials!(layer::Main.Layer)
    validTiles = Main.validTiles(layer)
    tileNames = Main.tileNames(layer)

    Main.setMaterialList!([tileNames[mat] for mat in validTiles], row -> row[1] == tileNames[material])
end

function toolSelected(subTools::Main.ListContainer, layers::Main.ListContainer, materials::Main.ListContainer)
    layerName = Main.layerName(targetLayer)
    tileNames = Main.tileNames(targetLayer)
    global material = get(Main.persistence, "brushes_material_$(layerName)", tileNames["Air"])[1]

    wantedLayer = get(Main.persistence, "brushes_layer", "fgTiles")
    Main.updateLayerList!(["fgTiles", "bgTiles"], row -> row[1] == wantedLayer)

    Main.redrawingFuncs["tools"] = drawLines
    Main.redrawLayer!(toolsLayer)
end

function layerSelected(list::Main.ListContainer, materials::Main.ListContainer, selected::String)
    global targetLayer = Main.getLayerByName(drawingLayers, selected)
    Main.persistence["brushes_layer"] = selected

    tileNames = Main.tileNames(targetLayer)
    global material = get(Main.persistence, "brushes_material_$(selected)", tileNames["Air"])[1]
    setMaterials!(targetLayer)
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
    global targetLayer = Main.selectLayer!(layers, wantedLayer, "fgTiles")
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

function selectionMotion(x1::Number, y1::Number, x2::Number, y2::Number)
    newLine = Main.Line(x1, y1, x2, y2)

    if newLine != line
        global line = newLine

        Main.redrawLayer!(toolsLayer)
    end
end

function selectionFinish(x1::Number, y1::Number, x2::Number, y2::Number)
    roomTiles = Main.roomTiles(targetLayer, Main.loadedState.room)
    applyLine!(line, roomTiles, material)

    global line = nothing

    Main.redrawLayer!(toolsLayer)
    Main.redrawLayer!(targetLayer)
end

end