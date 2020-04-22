module Lines

using ..Ahorn, Maple

displayName = "Lines"
group = "Brushes"

drawingLayers = Ahorn.Layer[]

toolsLayer = nothing
targetLayer = nothing
material = '0'

line = nothing
lineBrush = nothing

function drawLine(line::Ahorn.Line, layer::Ahorn.Layer)
    points = Ahorn.pointsOnLine(line)
    pixels, ox, oy = Ahorn.nodesToBrushPixels(points)
    global lineBrush = Ahorn.Brush("Line", pixels, (ox, oy))

    Ahorn.drawBrush(lineBrush, layer, 1, 1)
end

function drawLines(layer::Ahorn.Layer, room::Ahorn.Room)
    if line != nothing
        drawLine(line, toolsLayer)
    end
end

function applyLine!(line::Ahorn.Line, material::Char)
    Ahorn.History.addSnapshot!(Ahorn.History.RoomSnapshot("Line $(material)", Ahorn.loadedState.room))

    Maple.updateTileSize!(Ahorn.loadedState.room, '0', '0')
    tiles = Ahorn.roomTiles(targetLayer, Ahorn.loadedState.room)
    Ahorn.applyBrush!(lineBrush, tiles, material, 1, 1)
end

function cleanup()
    global line = nothing

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
    global material = get(Ahorn.persistence, "brushes_material_$(layerName)", tileNames["Air"])[1]

    wantedLayer = get(Ahorn.persistence, "brushes_layer", "fgTiles")
    Ahorn.updateLayerList!(["fgTiles", "bgTiles"], row -> row[1] == wantedLayer)

    Ahorn.redrawingFuncs["tools"] = drawLines
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

function leftClick(x::Number, y::Number)
    if line !== nothing
        applyLine!(line, material)

        global line = nothing

        Ahorn.redrawLayer!(toolsLayer)
        Ahorn.redrawLayer!(targetLayer)
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

function mouseMotion(x::Number, y::Number)
    # Only make a preview square if we aren't dragging
    if !Ahorn.mouseButtonHeld(0x1)
        newLine = Ahorn.Line(x, y, x, y)
        
        if newLine != line
            global line = newLine
    
            Ahorn.redrawLayer!(toolsLayer)
        end
    end
end

function selectionMotion(x1::Number, y1::Number, x2::Number, y2::Number)
    newLine = Ahorn.Line(x1, y1, x2, y2)

    if newLine != line
        global line = newLine

        Ahorn.redrawLayer!(toolsLayer)
    end
end

function selectionFinish(x1::Number, y1::Number, x2::Number, y2::Number)
    if line !== nothing
        applyLine!(line, material)

        global line = nothing

        Ahorn.redrawLayer!(toolsLayer)
        Ahorn.redrawLayer!(targetLayer)
    end
end

end