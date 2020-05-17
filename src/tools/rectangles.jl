module Rectangles

using ..Ahorn, Maple

displayName = "Rectangles"
group = "Brushes"

drawingLayers = Ahorn.Layer[]

toolsLayer = nothing
targetLayer = nothing

material = '0'
filled = true

selection = nothing
rectangleBrush = nothing

function drawRectangle(rect::Ahorn.Rectangle, layer::Ahorn.Layer, filled=filled)
    pixels = fill(true, rect.h, rect.w)
    if !filled
        pixels[2:end - 1, 2:end - 1] .= false
    end

    global rectangleBrush = Ahorn.Brush("Rectangle", pixels)

    Ahorn.drawBrush(rectangleBrush, layer, rect.x, rect.y)
end

function drawRectangles(layer::Ahorn.Layer, room::Ahorn.DrawableRoom, camera::Ahorn.Camera)
    if selection !== nothing
        drawRectangle(selection, toolsLayer)
    end
end

function applyRectangle!(rect::Ahorn.Rectangle, material::Char, filled)
    Ahorn.History.addSnapshot!(Ahorn.History.RoomSnapshot("Rectangle $(material)", Ahorn.loadedState.room))

    Maple.updateTileSize!(Ahorn.loadedState.room, '0', '0')
    tiles = Ahorn.roomTiles(targetLayer, Ahorn.loadedState.room)
    Ahorn.applyBrush!(rectangleBrush, tiles, material, rect.x, rect.y)
end

function cleanup()
    global selection = nothing

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

    wantedMode = get(Ahorn.persistence, "brushes_rectangle_mode", "Filled")
    Ahorn.updateTreeView!(subTools, ["Filled", "Hollow"], row -> row[1] == wantedMode)

    wantedLayer = get(Ahorn.persistence, "brushes_layer", "fgTiles")
    Ahorn.updateLayerList!(["fgTiles", "bgTiles"], row -> row[1] == wantedLayer)

    Ahorn.redrawingFuncs["tools"] = drawRectangles
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
    Ahorn.persistence["brushes_rectangle_mode"] = selected
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
    if selection !== nothing
        applyRectangle!(selection, material, filled)

        global selection = nothing

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
        newRect = Ahorn.Rectangle(x, y, 1, 1)
        
        if newRect != selection
            global selection = newRect
    
            Ahorn.redrawLayer!(toolsLayer)
        end
    end
end

function selectionMotion(rect::Ahorn.Rectangle)
    if rect != selection
        global selection = rect

        Ahorn.redrawLayer!(toolsLayer)
    end
end

function selectionFinish(rect::Ahorn.Rectangle)
    if selection !== nothing
        applyRectangle!(selection, material, filled)

        global selection = nothing

        Ahorn.redrawLayer!(toolsLayer)
        Ahorn.redrawLayer!(targetLayer)
    end
end

end