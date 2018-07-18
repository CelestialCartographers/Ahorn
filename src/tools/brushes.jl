module Brushes

displayName = "Brushes"
group = "Brushes"

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

function setMaterials!(layer::Main.Layer)
    validTiles = Main.validTiles(layer)
    tileNames = Main.tileNames(layer)

    Main.setMaterialList!([tileNames[mat] for mat in validTiles], row -> row[1] == tileNames[material])
end

function mouseMotion(x::Number, y::Number)
    global hoveringBrush = (x, y, deepcopy(selectedBrush))

    Main.redrawLayer!(toolsLayer)
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
    layer = Main.layerName(targetLayer)
    Main.History.addSnapshot!(Main.History.RoomSnapshot("Brush $(selectedBrush.name)", Main.loadedState.room))

    roomTiles = Main.roomTiles(targetLayer, Main.loadedState.room)
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
    if !isempty(phantomBrushes)
        Main.History.addSnapshot!(Main.History.RoomSnapshot("Brush ($(selectedBrush.name), $material)", Main.loadedState.room))    
    end

    for (pos, brush) in phantomBrushes
        x, y = pos

        roomTiles = Main.roomTiles(targetLayer, Main.loadedState.room)
        Main.applyBrush!(brush, roomTiles, material, x, y)
    end

    if !isempty(phantomBrushes)
        empty!(phantomBrushes)

        Main.redrawLayer!(targetLayer)
    end

    Main.redrawLayer!(toolsLayer)
end

function toolSelected(subTools::Main.ListContainer, layers::Main.ListContainer, materials::Main.ListContainer)
    layerName = Main.layerName(targetLayer)
    tileNames = Main.tileNames(targetLayer)
    global material = get(Main.persistence, "brushes_material_$(layerName)", tileNames["Air"])[1]

    wantedBrush = get(Main.persistence, "brushes_brushes_brush", brushes[1].name)
    Main.updateTreeView!(subTools, [brush.name for brush in brushes], row -> row[1] == wantedBrush)

    wantedLayer = get(Main.persistence, "brushes_layer", "fgTiles")
    Main.updateLayerList!(["fgTiles", "bgTiles"], row -> row[1] == wantedLayer)

    Main.redrawingFuncs["tools"] = drawBrushes
    Main.redrawLayer!(toolsLayer)
end

function layerSelected(list::Main.ListContainer, materials::Main.ListContainer, selected::String)
    global targetLayer = Main.getLayerByName(drawingLayers, selected)
    Main.persistence["brushes_layer"] = selected

    tileNames = Main.tileNames(targetLayer)
    layerName = Main.layerName(targetLayer)
    global material = get(Main.persistence, "brushes_material_$(layerName)", tileNames["Air"])[1]
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

function subToolSelected(list::Main.ListContainer, selected::String)
    for brush in brushes
        if brush.name == selected
            Main.persistence["brushes_brushes_brush"] = selected
            global selectedBrush = brush
        end
    end
end

function keyboard(event::Main.eventKey)
    if event.keyval == Main.keyval("l")
        selectedBrush.rotation = mod(selectedBrush.rotation + 1, 4)

    elseif event.keyval == Main.keyval("r")
        selectedBrush.rotation = mod(selectedBrush.rotation - 1, 4)
    end
end

end