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
    Main.applyBrush!(rectangleBrush, tiles, material, rect.x, rect.y)
end

function cleanup()
    global selection = nothing

    Main.redrawLayer!(toolsLayer)
end

function setMaterials!(layer::Main.Layer, materials::Main.ListContainer)
    validTiles = layer.name == "fgTiles"? Main.Maple.valid_fg_tiles : Main.Maple.valid_bg_tiles

    Main.updateTreeView!(materials, [Main.Maple.tile_names[mat] for mat in validTiles], row -> row[1] == Main.Maple.tile_names[material])
end

function toolSelected(subTools::Main.ListContainer, layers::Main.ListContainer, materials::Main.ListContainer)
    global material = get(Main.persistence, "brushes_material", Main.Maple.tile_names["Air"])[1]

    wantedMode = get(Main.persistence, "brushes_rectangle_mode", "Filled")
    Main.updateTreeView!(subTools, ["Filled", "Hollow"], row -> row[1] == wantedMode)

    wantedLayer = get(Main.persistence, "brushes_layer", "fgTiles")
    Main.updateTreeView!(layers, ["fgTiles", "bgTiles"], row -> row[1] == wantedLayer)

    Main.redrawingFuncs["tools"] = drawRectangles
    Main.redrawLayer!(toolsLayer)
end

function layerSelected(list::Main.ListContainer, materials::Main.ListContainer, selected::String)
    global targetLayer = Main.getLayerByName(drawingLayers, selected)
    Main.persistence["brushes_layer"] = selected

    setMaterials!(targetLayer, materials)
end

function subToolSelected(list::Main.ListContainer, selected::String)
    Main.persistence["brushes_rectangle_mode"] = selected
    global filled = selected == "Filled"
end

function materialSelected(list::Main.ListContainer, selected::String)
    Main.persistence["brushes_material"] = Main.Maple.tile_names[selected]
    global material = Main.Maple.tile_names[selected]
end

function layersChanged(layers::Array{Main.Layer, 1})
    wantedLayer = get(Main.persistence, "brushes_layer", "fgTiles")

    global drawingLayers = layers
    global toolsLayer = Main.getLayerByName(layers, "tools")
    global targetLayer = Main.updateLayerList!(layers, wantedLayer, "fgTiles")
end

function middleClick(x::Number, y::Number)
    tiles = Main.layerName(targetLayer) == "fgTiles"? Main.loadedRoom.fgTiles : Main.loadedRoom.bgTiles
    target = get(tiles.data, (y, x), '0')

    global material = target
    Main.persistence["brushes_material"] = material
    Main.selectMaterialList!(Main.Maple.tile_names[target])
end

function selectionMotion(rect::Main.Rectangle)
    if rect != selection
        global selection = rect

        Main.redrawLayer!(toolsLayer)
    end
end

function selectionFinish(rect::Main.Rectangle)
    roomTiles = Main.layerName(targetLayer) == "fgTiles"? Main.loadedRoom.fgTiles : Main.loadedRoom.bgTiles
    applyRectangle!(selection, roomTiles, material, filled)

    global selection = nothing

    Main.redrawLayer!(toolsLayer)
    Main.redrawLayer!(targetLayer)
end

end