module Brushes

displayName = "Brushes"

drawingLayers = Main.Layer[]

toolsLayer = nothing
targetLayer = nothing
material = '0'

brushes = Main.Brush[
    Main.Brush(
        "Pencil",
        hcat(1)
    ),

    Main.Brush(
        "Dither",
        [
            1 0;
            0 1
        ]
    ),
    Main.Brush(
        "Ahorn",
        [
            0 0 1 0 0 0 0;
            0 1 0 1 0 0 0;
            0 0 0 1 1 0 1;
            0 0 1 1 1 0 0;
            0 1 1 1 1 1 0;
            0 1 1 1 1 1 0;
            1 1 1 1 1 1 0;
            1 1 1 1 1 0 0;
            0 1 1 1 0 0 0;
        ]
    )
]

selectedBrush = brushes[1]

hoveringBrush = nothing
phantomBrushes = Dict{Tuple{Integer, Integer}, Main.Brush}()

function drawBrushes(layer::Main.Layer, room::Main.Maple.Room)
    if !isa(hoveringBrush, Void)
        x, y, brush = hoveringBrush

        Main.drawBrush(brush, layer, x, y)
    end

    for (pos, brush) in phantomBrushes
         x, y = pos

         Main.drawBrush(brush, layer, x, y)
    end
end

function cleanup()
    global hoveringBrush = nothing
    empty!(phantomBrushes)

    Main.redrawLayer!(toolsLayer)
end

function setMaterials!(layer::Main.Layer, materials::Main.ListContainer)
    validTiles = layer.name == "fgTiles"? Main.Maple.valid_fg_tiles : Main.Maple.valid_bg_tiles

    Main.updateTreeView!(materials, [Main.Maple.tile_names[mat] for mat in validTiles], row -> row[1] == Main.Maple.tile_names[material])
end

function mouseMotion(x::Number, y::Number)
    global hoveringBrush = (x, y, deepcopy(selectedBrush))

    Main.redrawLayer!(toolsLayer)
end

function middleClick(x::Number, y::Number)
    tiles = Main.layerName(targetLayer) == "fgTiles"? Main.loadedRoom.fgTiles : Main.loadedRoom.bgTiles
    target = get(tiles.data, (y, x), '0')

    global material = target
    Main.selectMaterialList!(Main.Maple.tile_names[target])
end

function leftClick(x::Number, y::Number)
    roomTiles = Main.layerName(targetLayer) == "fgTiles"? Main.loadedRoom.fgTiles : Main.loadedRoom.bgTiles
    Main.applyBrush!(selectedBrush, roomTiles, material, x, y)

    Main.redrawLayer!(targetLayer)
end

function selectionMotion(x1::Number, y1::Number, x2::Number, y2::Number)
    box, boy = selectedBrush.offset

    startX = x1
    startY = y1
    
    pixels = rotr90(selectedBrush.pixels, selectedBrush.rotation)

    bh, bw = size(pixels)
    ox, oy = mod(startX, bw), mod(startY, bh)

    bx, by = div(x2, bw) * bw + ox - box + 1, div(y2, bh) * bh + oy - boy + 1

    if !haskey(phantomBrushes, (bx, by)) 
        phantomBrushes[(bx, by)] = deepcopy(selectedBrush)

        Main.redrawLayer!(toolsLayer)
    end
end

function selectionFinish(rect::Main.Rectangle)
    for (pos, brush) in phantomBrushes
        x, y = pos

        roomTiles = Main.layerName(targetLayer) == "fgTiles"? Main.loadedRoom.fgTiles : Main.loadedRoom.bgTiles
        Main.applyBrush!(brush, roomTiles, material, x, y)
    end

    if length(phantomBrushes) > 0
        empty!(phantomBrushes)

        Main.redrawLayer!(targetLayer)
    end

    Main.redrawLayer!(toolsLayer)
end

function toolSelected(subTools::Main.ListContainer, layers::Main.ListContainer, materials::Main.ListContainer)
    Main.updateTreeView!(subTools, [brush.name for brush in brushes])
    Main.updateTreeView!(layers, ["fgTiles", "bgTiles"], row -> row[1] == Main.layerName(targetLayer))

    Main.redrawingFuncs["tools"] = drawBrushes
    Main.redrawLayer!(toolsLayer)
end

function layerSelected(list::Main.ListContainer, materials::Main.ListContainer, selected::String)
    global targetLayer = Main.getLayerByName(drawingLayers, selected)

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

function subToolSelected(list::Main.ListContainer, selected::String)
    for brush in brushes
        if brush.name == selected
            global selectedBrush = brush
        end
    end
end

# Test brush rotation
function keyboard(event::Main.eventKey)
    # Numbers 0:9
    if event.keyval in 48:57
        global selectedBrush = get(brushes, event.keyval - 47, brushes[1])

    elseif event.keyval == Main.keyval("l")
        selectedBrush.rotation = mod(selectedBrush.rotation + 1, 4)

    elseif event.keyval == Main.keyval("r")
        selectedBrush.rotation = mod(selectedBrush.rotation - 1, 4)
    end
end

end