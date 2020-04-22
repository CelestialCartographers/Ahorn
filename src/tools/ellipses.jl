module Ellipses

using ..Ahorn, Maple

displayName = "Ellipses"
group = "Brushes"

drawingLayers = Ahorn.Layer[]

toolsLayer = nothing
targetLayer = nothing
material = '0'

filled = false

ellipse = nothing
ellipseBrush = nothing

function drawEllipse(ellipse::Ahorn.Ellipse, layer::Ahorn.Layer)
    points = Ahorn.pointsOnEllipse(ellipse, filled=filled)
    pixels, ox, oy = Ahorn.nodesToBrushPixels(points)
    global ellipseBrush = Ahorn.Brush("Ellipse", pixels, (ox, oy))

    Ahorn.drawBrush(ellipseBrush, layer, 1, 1)
end

function drawEllipses(layer::Ahorn.Layer, room::Ahorn.Room)
    if ellipse != nothing
        drawEllipse(ellipse, toolsLayer)
    end
end

function applyEllipse!(ellipse::Ahorn.Ellipse, material::Char)
    layer = Ahorn.layerName(targetLayer)
    Ahorn.History.addSnapshot!(Ahorn.History.RoomSnapshot("Ellipse $(material)", Ahorn.loadedState.room))

    Maple.updateTileSize!(Ahorn.loadedState.room, '0', '0')
    tiles = Ahorn.roomTiles(targetLayer, Ahorn.loadedState.room)
    Ahorn.applyBrush!(ellipseBrush, tiles, material, 1, 1)
end

function cleanup()
    global ellipse = nothing

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

    wantedMode = get(Ahorn.persistence, "brushes_ellipse_mode", "Filled")
    Ahorn.updateTreeView!(subTools, ["Filled", "Hollow"], row -> row[1] == wantedMode)

    Ahorn.redrawingFuncs["tools"] = drawEllipses
    Ahorn.redrawLayer!(toolsLayer)
end

function layerSelected(list::Ahorn.ListContainer, materials::Ahorn.ListContainer, selected::String)
    global targetLayer = Ahorn.getLayerByName(drawingLayers, selected)
    Ahorn.persistence["brushes_layer"] = selected

    tileNames = Ahorn.tileNames(targetLayer)
    global material = get(Ahorn.persistence, "brushes_material_$(selected)", tileNames["Air"])[1]
    setMaterials!(targetLayer)
end

function subToolSelected(list::Ahorn.ListContainer, selected::String)
    Ahorn.persistence["brushes_ellipse_mode"] = selected
    global filled = selected == "Filled"
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
    if ellipse !== nothing
        applyEllipse!(ellipse, material)

        global ellipse = nothing

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
        newEllipse = Ahorn.Ellipse(x, y, 0, 0)
        
        if newEllipse != ellipse
            global ellipse = newEllipse
    
            Ahorn.redrawLayer!(toolsLayer)
        end
    end
end

function selectionMotion(x1::Number, y1::Number, x2::Number, y2::Number)
    newEllipse = Ahorn.Ellipse(x1, y1, abs(x1 - x2), abs(y1 - y2))

    if newEllipse != ellipse
        global ellipse = newEllipse

        Ahorn.redrawLayer!(toolsLayer)
    end
end

function selectionFinish(x1::Number, y1::Number, x2::Number, y2::Number)
    if ellipse !== nothing
        applyEllipse!(ellipse, material)

        global ellipse = nothing

        Ahorn.redrawLayer!(toolsLayer)
        Ahorn.redrawLayer!(targetLayer)
    end
end

end