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
    Main.applyBrush!(lineBrush, tiles, material, 1, 1)
end

function cleanup()
    global line = nothing

    Main.redrawLayer!(toolsLayer)
end

function setMaterials!(layer::Main.Layer, materials::Main.ListContainer)
    validTiles = layer.name == "fgTiles"? Main.Maple.valid_fg_tiles : Main.Maple.valid_bg_tiles

    Main.updateTreeView!(materials, [Main.Maple.tile_names[mat] for mat in validTiles], row -> row[1] == Main.Maple.tile_names[material])
end

function toolSelected(subTools::Main.ListContainer, layers::Main.ListContainer, materials::Main.ListContainer)
    Main.updateTreeView!(layers, ["fgTiles", "bgTiles"], row -> row[1] == Main.layerName(targetLayer))

    Main.redrawingFuncs["tools"] = drawLines
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

function middleClick(x::Number, y::Number)
    tiles = Main.layerName(targetLayer) == "fgTiles"? Main.loadedRoom.fgTiles : Main.loadedRoom.bgTiles
    target = get(tiles.data, (y, x), '0')

    global material = target
    Main.selectMaterialList!(Main.Maple.tile_names[target])
end

function selectionMotion(x1::Number, y1::Number, x2::Number, y2::Number)
    newLine = Main.Line(x1, y1, x2, y2)

    if newLine != line
        global line = newLine

        Main.redrawLayer!(toolsLayer)
    end
end

function selectionFinish(x1::Number, y1::Number, x2::Number, y2::Number)
    roomTiles = Main.layerName(targetLayer) == "fgTiles"? Main.loadedRoom.fgTiles : Main.loadedRoom.bgTiles
    applyLine!(line, roomTiles, material)

    global line = nothing

    Main.redrawLayer!(toolsLayer)
    Main.redrawLayer!(targetLayer)
end

end