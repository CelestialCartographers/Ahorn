module Rectangles

displayName = "Rectangles"
group = "Brushes"

drawingLayers = Main.Layer[]

toolsLayer = nothing
targetLayer = nothing

material = '0'
filled = true

selection = nothing
rectangleBrush = nothing

function drawRectangle(rect::Main.Rectangle, layer::Main.Layer, filled=filled)
    ctx = Main.creategc(layer.surface)

    pixels = fill(true, rect.h, rect.w)
    if !filled
        pixels[2:end - 1, 2:end - 1] = false
    end

    global rectangleBrush = Main.Brush("Rectangle", pixels)

    Main.drawBrush(rectangleBrush, layer, rect.x, rect.y)
end

function drawRectangles(layer::Main.Layer, room::Main.Room)
    if selection != nothing
        drawRectangle(selection, toolsLayer)
    end
end

function applyRectangle!(rect::Main.Rectangle, tiles::Main.Maple.Tiles, material::Char, filled)
    layer = Main.layerName(targetLayer)
    Main.History.addSnapshot!(Main.History.RoomSnapshot("Rectangle $(material)", Main.loadedState.room))

    Main.applyBrush!(rectangleBrush, tiles, material, rect.x, rect.y)
end

function cleanup()
    global selection = nothing

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

    wantedMode = get(Main.persistence, "brushes_rectangle_mode", "Filled")
    Main.updateTreeView!(subTools, ["Filled", "Hollow"], row -> row[1] == wantedMode)

    wantedLayer = get(Main.persistence, "brushes_layer", "fgTiles")
    Main.updateLayerList!(["fgTiles", "bgTiles"], row -> row[1] == wantedLayer)

    Main.redrawingFuncs["tools"] = drawRectangles
    Main.redrawLayer!(toolsLayer)
end

function layerSelected(list::Main.ListContainer, materials::Main.ListContainer, selected::String)
    global targetLayer = Main.getLayerByName(drawingLayers, selected)
    Main.persistence["brushes_layer"] = selected

    tileNames = Main.tileNames(targetLayer)
    global material = get(Main.persistence, "brushes_material_$(selected)", tileNames["Air"])[1]
    setMaterials!(targetLayer)
end

function subToolSelected(list::Main.ListContainer, selected::String)
    Main.persistence["brushes_rectangle_mode"] = selected
    global filled = selected == "Filled"
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

function leftClick(x::Number, y::Number)
    roomTiles = Main.roomTiles(targetLayer, Main.loadedState.room)
    applyRectangle!(selection, roomTiles, material, filled)

    global selection = nothing

    Main.redrawLayer!(toolsLayer)
    Main.redrawLayer!(targetLayer)
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

function mouseMotion(x::Number, y::Number)
    # Only make a preview square if we aren't dragging
    if !Main.mouseButtonHeld(0x1)
        newRect = Main.Rectangle(x, y, 1, 1)
        
        if newRect != selection
            global selection = newRect
    
            Main.redrawLayer!(toolsLayer)
        end
    end
end

function selectionMotion(rect::Main.Rectangle)
    if rect != selection
        global selection = rect

        Main.redrawLayer!(toolsLayer)
    end
end

function selectionFinish(rect::Main.Rectangle)
    roomTiles = Main.roomTiles(targetLayer, Main.loadedState.room)
    applyRectangle!(selection, roomTiles, material, filled)

    global selection = nothing

    Main.redrawLayer!(toolsLayer)
    Main.redrawLayer!(targetLayer)
end

end