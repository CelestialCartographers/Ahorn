module Selection

using ..Ahorn, Maple

displayName = "Selection"
group = "Placements"

drawingLayers = Ahorn.Layer[]

toolsLayer = nothing
targetLayer = nothing

# Drag selection, track individually for easy replacement
selectionRect = Ahorn.Rectangle(0, 0, 0, 0)
selectionPreviews = Set{Ahorn.SelectedObject}()
selections = Set{Ahorn.SelectedObject}()

areaOperationArea = nothing

lastX, lastY = -1, -1
shouldDrag = false
canDrag = false

decalScaleVals = (1.0, 2.0^4)

canResize = false
resizeCursor = "default"
cursorResizeThreshold = 1

const resizeCursorDirections = Dict{String, Tuple{Int, Int}}(
    "n-resize" => (0, -1),
    "ne-resize" => (1, -1),
    "e-resize" => (1, 0),
    "se-resize" => (1, 1),
    "s-resize" => (0, 1),
    "sw-resize" => (-1, 1),
    "w-resize" => (-1, 0),
    "nw-resize" => (-1, -1),
)

relevantRoom = Ahorn.loadedState.room
selectionsClipboard = Set{Ahorn.SelectedObject}()

function copySelections(cut::Bool=false)
    if isempty(selections)
        return false
    end

    empty!(selectionsClipboard)
    union!(selectionsClipboard, deepcopy(selections))

    if cut
        handleDeletion(selections)
        empty!(selections)
    end

    toolsLayer.redraw = true
    redrawTargetLayer!(targetLayer, selectionsClipboard)

    return cut
end

cutSelections() = copySelections(true)

function getCursorForResize(x::Int, y::Int, rect::Ahorn.Rectangle, canHorizontal::Bool=true, canVertical::Bool=true, threshold::Number=cursorResizeThreshold)
    if !(canHorizontal || canVertical)
        return "default"
    end

    res = ""

    onHorizontal = rect.x - threshold <= x <= rect.x + rect.w + threshold
    onVertical = rect.y - threshold <= y <= rect.y + rect.h + threshold

    onNorthLine = onHorizontal && (rect.y - threshold <= y <= rect.y + threshold)
    onSouthLine = onHorizontal && (rect.y + rect.h - threshold <= y <= rect.y + rect.h + threshold)
    onWestLine = onVertical && (rect.x - threshold <= x <= rect.x + threshold)
    onEastLine = onVertical && (rect.x + rect.w - threshold <= x <= rect.x + rect.w + threshold)

    if onNorthLine && canVertical
        res *= "n"

    elseif onSouthLine && canVertical
        res *= "s"
    end

    if onWestLine && canHorizontal
        res *= "w"

    elseif onEastLine && canHorizontal
        res *= "e"
    end

    return isempty(res) ? "default" : res * "-resize"
end

# Windows doesn't have "grabbing" and "grab"
function updateCursor()
    cursor = "default"

    if canResize
        cursor = resizeCursor
        
    elseif shouldDrag
        cursor = Sys.iswindows() ? "default" : "grabbing"

    elseif canDrag 
        cursor = Sys.iswindows() ? "default" : "grab"
    end

    Ahorn.setWindowCursor!(Ahorn.window, cursor)
end

function getSelectionLeftCorner(selections::Set{Ahorn.SelectedObject})
    tlx, tly = typemax(Int), typemax(Int)

    for selection in selections
        x, y = Ahorn.position(selection.target)

        tlx = min(tlx, x)
        tly = min(tly, y)
    end

    return tlx, tly
end

getUpdatedRectangle(selection::Ahorn.SelectedObject, target::Ahorn.TileSelection) = target.selection

function getUpdatedRectangle(selection::Ahorn.SelectedObject, target::Ahorn.Decal)
    Ahorn.getSelection(target, relevantRoom)
end

function getUpdatedRectangle(selection::Ahorn.SelectedObject, target::Union{Maple.Entity, Maple.Trigger})
    node = selection.node
    rectangle = Ahorn.getSelection(target, relevantRoom)

    if isa(rectangle, Ahorn.Rectangle)
        return rectangle

    else
        return rectangle[node + 1]
    end
end

function getSelectionArea(fitToGrid::Bool=true)
    rectangles = [
        getUpdatedRectangle(selection, selection.target)
        for selection in selections
    ]

    baseArea = Ahorn.coverRectangles(rectangles)

    if fitToGrid
        offsetX, offsetY = baseArea.x % 8, baseArea.y % 8
        width, height = baseArea.w + offsetX, baseArea.h + offsetY
        width = width % 8 == 0 ? width : ceil(Int, width / 8) * 8
        height = height % 8 == 0 ? height : ceil(Int, height / 8) * 8

        return Ahorn.Rectangle(baseArea.x - offsetX, baseArea.y - offsetY, width, height)

    else
        return baseArea
    end
end

function pasteSelections()
    if isempty(selectionsClipboard)
       return false
    end

    newSelections = deepcopy(selectionsClipboard)
    room = relevantRoom

    offsetX, offsetY = 0, 0

    if Ahorn.cursor !== nothing
        topLeftX, topLeftY = getSelectionLeftCorner(newSelections)

        offsetX = -topLeftX + Ahorn.cursor.x * 8 - 8
        offsetY = -topLeftY + Ahorn.cursor.y * 8 - 8
    end

    for selection in newSelections
        layer, box, target, node = selection.layerName, selection.rectangle, selection.target, selection.node

        if layer == "fgDecals"
            target.x += offsetX
            target.y += offsetY

            push!(room.fgDecals, target)

        elseif layer == "bgDecals"
            target.x += offsetX
            target.y += offsetY

            push!(room.bgDecals, target)

        elseif layer == "entities" && node == 0
            target.x += offsetX
            target.y += offsetY

            if haskey(target.data, "nodes")
                target.nodes = Tuple{Integer, Integer}[(x + offsetX, y + offsetY) for (x, y) in target.nodes]
            end

            target.id = Ahorn.EntityIds.nextId()

            push!(room.entities, target)

        elseif layer == "triggers" && node == 0
            target.x += offsetX
            target.y += offsetY

            if haskey(target.data, "nodes")
                target.nodes = Tuple{Integer, Integer}[(x + offsetX, y + offsetY) for (x, y) in target.nodes]
            end

            target.id = Ahorn.EntityIds.nextId()

            push!(room.triggers, target)

        elseif layer == "fgTiles" || layer == "bgTiles"
            target.offsetX += offsetX
            target.offsetY += offsetY

            target.selection = Ahorn.Rectangle(
                target.selection.x + offsetX,
                target.selection.y + offsetY,
                target.selection.w,
                target.selection.h
            )
        end
    end

    finalizeSelections!(selections)
    empty!(selections)
    union!(selections, newSelections)

    toolsLayer.redraw = true
    redrawTargetLayer!(targetLayer, selections)

    return true
end

hotkeys = Ahorn.Hotkey[
    Ahorn.Hotkey(
        "ctrl + c",
        copySelections
    ),
    Ahorn.Hotkey(
        "ctrl + x",
        cutSelections
    ),
    Ahorn.Hotkey(
        "ctrl + v",
        pasteSelections
    )
]

function drawSelections(layer::Ahorn.Layer, room::Ahorn.DrawableRoom, camera::Ahorn.Camera)
    drawnTargets = Set()
    ctx = Ahorn.getSurfaceContext(toolsLayer.surface)

    # Prone to errors with weird pointers, bandaid fix for now
    # This might not actually be needed, but i'm keeping it for now
    if ctx.surface.ptr == C_NULL || ctx.ptr == C_NULL
        return true
    end

    if selectionRect !== nothing && selectionRect.w > 0 && selectionRect.h > 0 && !shouldDrag
        Ahorn.drawRectangle(ctx, selectionRect, Ahorn.colors.selection_selection_fc, Ahorn.colors.selection_selection_bc)
    end

    # Make sure fgTiles render after the bgTiles
    # Looks better, shouldn't cost to much performance
    selectionsArray = collect(selections)
    sort!(selectionsArray, by=r -> r.layerName)

    for selection in selectionsArray
        layer, box, target, node = selection.layerName, selection.rectangle, selection.target, selection.node

        if isa(target, Maple.Entity) && !(target in [row[1] for row in drawnTargets])
            Ahorn.renderEntitySelection(ctx, toolsLayer, target, relevantRoom)
        end

        if isa(target, Maple.Trigger) && !(target in [row[1] for row in drawnTargets])
            Ahorn.renderTriggerSelection(ctx, toolsLayer, target, relevantRoom)
        end

        if isa(target, Ahorn.TileSelection)
            Ahorn.drawFakeTiles(ctx, relevantRoom, target.tiles, relevantRoom.objTiles, target.fg, target.selection.x, target.selection.y, clipEdges=true)
        end

        push!(drawnTargets, (target, node))

        # Get a new selection rectangle
        # This is easier than editing the existing rect
        rect = Ahorn.getSelection(target, room.room)
        if isa(rect, Array{Ahorn.Rectangle}) && length(rect) >= node + 1
            Ahorn.drawRectangle(ctx, rect[node + 1], Ahorn.colors.selection_selected_fc, Ahorn.colors.selection_selected_bc)

        else
            Ahorn.drawRectangle(ctx, rect, Ahorn.colors.selection_selected_fc, Ahorn.colors.selection_selected_bc)
        end
    end

    if !shouldDrag
        for preview in selectionPreviews
            layer, box, target, node = preview.layerName, preview.rectangle, preview.target, preview.node

            if isa(target, Maple.Entity) && !(target in [row[1] for row in drawnTargets])
                Ahorn.renderEntitySelection(ctx, toolsLayer, target, relevantRoom)
            end

            if isa(target, Maple.Trigger) && !(target in [row[1] for row in drawnTargets])
                Ahorn.renderTriggerSelection(ctx, toolsLayer, target, relevantRoom)
            end

            if !((target, node) in drawnTargets) && !(preview in selections)
                Ahorn.drawRectangle(ctx, box, Ahorn.colors.selection_preview_fc, Ahorn.colors.selection_preview_bc)
            end

            push!(drawnTargets, (target, node))
        end
    end

    return true
end

function updateAreaOperationRectangle!(area::Ahorn.Rectangle)
    if areaOperationArea === nothing
        global areaOperationArea = area
    end

    return areaOperationArea
end

function clearAreaOperationRectangle!()
    global areaOperationArea = nothing
end

function clearDragging!()
    global lastX = -1
    global lastY = -1
    global shouldDrag = false
    global canDrag = false
end

function clearResize!()
    global resizeCursor = "default"
    global canResize = false
end

function clearSelections!()
    finalizeSelections!(selections)
    empty!(selections)
end

function cleanup()
    finalizeSelections!(selections)
    empty!(selections)

    global selectionRect = Ahorn.Rectangle(0, 0, 0, 0)
    global relevantRoom = Ahorn.loadedState.room
    global targetLayer = nothing
    global toolsLayer = nothing
    global drawingLayers = Ahorn.Layer[]

    clearDragging!()
    clearResize!()
    updateCursor()
end

function toolSelected(subTools::Ahorn.ListContainer, layers::Ahorn.ListContainer, materials::Ahorn.ListContainer)
    global relevantRoom = Ahorn.loadedState.room

    wantedLayer = get(Ahorn.persistence, "placements_layer", "entities")
    Ahorn.updateLayerList!(vcat(["all"], Ahorn.selectableLayers), row -> row[1] == Ahorn.layerName(targetLayer))

    Ahorn.redrawingFuncs["tools"] = drawSelections
    Ahorn.redrawLayer!(toolsLayer)
end

function layerSelected(list::Ahorn.ListContainer, materials::Ahorn.ListContainer, selected::String)
    global targetLayer = Ahorn.getLayerByName(drawingLayers, selected)
    Ahorn.persistence["placements_layer"] = selected
end

function updateSelectionPreviews(x::Int, y::Int)
    if get(Ahorn.config, "preview_possible_selections", true)
        if selectionRect == Ahorn.Rectangle(0, 0, 0, 0)
            # Don't preview tile selections or "all" selection
            # It looks weird and it can cause deletion of tiles

            name = Ahorn.layerName(targetLayer)
            if name != "fgTiles" && name != "bgTiles" && name != "all"
                previousPreviews = deepcopy(selectionPreviews)
                finalizeSelections!(selectionPreviews)
                empty!(selectionPreviews)
                rect = Ahorn.Rectangle(x, y, 1, 1)
                properlyUpdateSelections!(rect, selectionPreviews, best=true)

                sameSelections = previousPreviews == selectionPreviews

                if !sameSelections
                    Ahorn.redrawLayer!(toolsLayer)
                end
            end
        end
    end
end

function updateResize(x::Int, y::Int)
    if !shouldDrag && length(selections) == 1 && !Ahorn.mouseButtonHeld(0x1)
        selection = first(selections)
        layer, box, target, node = selection.layerName, selection.rectangle, selection.target, selection.node
        selectionRect = Ahorn.getSelection(target, Ahorn.loadedState.room)
        rect = isa(selectionRect, Array{Ahorn.Rectangle, 1}) ? selectionRect[1] : selectionRect
        
        if isa(rect, Ahorn.Rectangle) && (isa(target, Maple.Entity) || isa(target, Maple.Trigger)) && node == 0
            resizeW, resizeH = Ahorn.canResizeWrapper(target)

            name = getCursorForResize(x, y, rect, resizeW, resizeH)

            global resizeCursor = name
            global canResize = name != "default"
        end
    end
end

function updateDrag(x::Int, y::Int)
    if !shouldDrag
        target = Ahorn.hasSelectionAt(selections, Ahorn.Rectangle(x, y, 1, 1), relevantRoom)
        global canDrag = target != false
    end
end

function selectionMotionAbs(rect::Ahorn.Rectangle)
    if rect != selectionRect && !shouldDrag && !canResize
        if get(Ahorn.config, "preview_possible_selections", true)
            # Don't preview tile selections or "all" selection
            # It looks weird and it can cause deletion of tiles

            name = Ahorn.layerName(targetLayer)
            if name != "fgTiles" && name != "bgTiles" && name != "all"
                finalizeSelections!(selectionPreviews)
                empty!(selectionPreviews)

                properlyUpdateSelections!(rect, selectionPreviews)
            end
        end
        
        global selectionRect = rect

        Ahorn.redrawLayer!(toolsLayer)
    end
end

function selectionMotionAbs(x1::Number, y1::Number, x2::Number, y2::Number)
    ctrl = Ahorn.modifierControl()

    if lastX == -1 && lastY == -1
        global lastX = ctrl ? x1 : div(x1, 8) * 8
        global lastY = ctrl ? y1 : div(y1, 8) * 8

        if !shouldDrag && canDrag
            global shouldDrag = true

            Ahorn.History.addSnapshot!(Ahorn.History.MultiSnapshot("Selections", Ahorn.History.Snapshot[
                Ahorn.History.RoomSnapshot("Selections", Ahorn.loadedState.room),
                Ahorn.History.SelectionSnapshot("Selections", relevantRoom, selections)
            ]))
        end
    end

    if !Ahorn.modifierControl()
        x1 = div(x1, 8) * 8
        y1 = div(y1, 8) * 8

        x2 = div(x2, 8) * 8
        y2 = div(y2, 8) * 8
    end

    dx = x2 - lastX
    dy = y2 - lastY

    global lastX = x2
    global lastY = y2

    if canResize
        if (dx != 0 || dy != 0) && length(selections) == 1
            selection = first(selections)
            layer, box, target, node = selection.layerName, selection.rectangle, selection.target, selection.node

            if isa(target, Maple.Trigger) || isa(target, Maple.Entity)
                changed = false
                resizeX, resizeY = get(resizeCursorDirections, resizeCursor, (0, 0))

                resizeWidth, resizeHeight = Ahorn.canResizeWrapper(target)
                minimumWidth, minimumHeight = Ahorn.minimumSizeWrapper(target)

                if resizeX != 0 && resizeWidth
                    if target.width + dx * resizeX >= minimumWidth
                        target.width = target.width + dx * resizeX
                        target.x = target.x + dx * (resizeX < 0)

                        changed |= true
                    end
                end

                if resizeY != 0 && resizeHeight
                    if target.height + dy * resizeY >= minimumHeight
                        target.height = target.height + dy * resizeY
                        target.y = target.y + dy * (resizeY < 0)

                        changed |= true
                    end
                end

                if changed
                    snapshot = Ahorn.History.MultiSnapshot("Selections", Ahorn.History.Snapshot[
                        Ahorn.History.RoomSnapshot("Selections", Ahorn.loadedState.room),
                        Ahorn.History.SelectionSnapshot("Selections", relevantRoom, selections)
                    ])

                    Ahorn.History.addSnapshot!(snapshot)

                    toolsLayer.redraw = true
                    Ahorn.redrawLayer!(Ahorn.getLayerByName(drawingLayers, layer))

                    clearAreaOperationRectangle!()
                end
            end
        end

    elseif shouldDrag
        global lastX = ctrl ? x2 : div(x2, 8) * 8
        global lastY = ctrl ? y2 : div(y2, 8) * 8

        if dx != 0 || dy != 0
            for selection in selections
               layer, box, target, node = selection.layerName, selection.rectangle, selection.target, selection.node

                if applyMovement!(target, dx, dy, node)
                    notifyMovement!(target)
                end
            end

            toolsLayer.redraw = true
            redrawTargetLayer!(targetLayer, selections, String["fgTiles", "bgTiles"], onlyMark=true)
            Ahorn.redrawCanvas!()

            clearAreaOperationRectangle!()
        end
    end
end

function mouseMotionAbs(x::Number, y::Number)
    updateDrag(x, y)
    updateSelectionPreviews(x, y)
    updateResize(x, y)

    updateCursor()
end

function properlyUpdateSelections!(rect::Ahorn.Rectangle, selections::Set{Ahorn.SelectedObject}; best::Bool=false, mass::Bool=false)
    retain = Ahorn.modifierShift()

    # Do this before we get new selections
    # This way tiles are settled back into place before we select
    if !retain
        finalizeSelections!(selections)
    end

    unselected, newlySelected = Ahorn.updateSelections!(selections, relevantRoom, Ahorn.layerName(targetLayer), rect, retain=retain, best=best, mass=mass)
    initSelections!(newlySelected)
end

function properlyMassSelection!(selections::Set{Ahorn.SelectedObject}, rect::Ahorn.Rectangle; strict::Bool=false)
    retain = Ahorn.modifierShift()

    # Do this before we get new selections
    # This way tiles are settled back into place before we select
    if !retain
        finalizeSelections!(selections)
    end

    unselected, newlySelected = Ahorn.updateSelections!(selections, relevantRoom, Ahorn.layerName(targetLayer), rect, retain=retain, best=strict, mass=true)
    initSelections!(newlySelected)
end

function getLayersSelected(selections::Set{Ahorn.SelectedObject})
    return unique([selection.layerName for selection in selections])
end

function redrawTargetLayer!(layer::Ahorn.Layer, selections::Set{Ahorn.SelectedObject}, ignore::Array{String, 1}=String[]; onlyMark::Bool=false)
    redrawTargetLayer!(layer, getLayersSelected(selections), ignore, onlyMark=onlyMark)
end

function redrawTargetLayer!(layer::Ahorn.Layer, layers::Array{String, 1}, ignore::Array{String, 1}=String[]; onlyMark::Bool=false)
    needsRedraw = filter(v -> !(v in ignore), layers)

    for layer in needsRedraw
        Ahorn.getLayerByName(drawingLayers, layer).redraw = true
    end

    if !isempty(needsRedraw) || onlyMark
        Ahorn.redrawCanvas!()
    end
end

function selectionFinishAbs(rect::Ahorn.Rectangle)
    # If we are draging we are techically not making a new selection
    if !shouldDrag
        properlyUpdateSelections!(rect, selections)
    end

    # Clear previews after movement drag
    if shouldDrag
        empty!(selectionPreviews)
    end

    clearDragging!()
    clearResize!()
    clearAreaOperationRectangle!()
    updateCursor()

    global selectionRect = Ahorn.Rectangle(0, 0, 0, 0)

    Ahorn.redrawLayer!(toolsLayer)
end

function leftClickAbs(x::Number, y::Number)
    rect = Ahorn.Rectangle(x, y, 1, 1)
    properlyUpdateSelections!(rect, selections, best=true)

    clearDragging!()
    clearResize!()
    clearAreaOperationRectangle!()
    updateCursor()

    Ahorn.redrawLayer!(toolsLayer)
end

function doubleLeftClickAbs(x::Number, y::Number)
    strict = Ahorn.modifierControl()
    rect = Ahorn.Rectangle(x, y, 1, 1)
    properlyMassSelection!(selections, rect, strict=strict)

    clearDragging!()
    clearResize!()

    Ahorn.redrawLayer!(toolsLayer)
end

function rightClickAbs(x::Number, y::Number)
    if !shouldDrag
        Ahorn.displayProperties(x, y, relevantRoom, targetLayer, toolsLayer, selections)

        clearDragging!()
        clearResize!()

        Ahorn.redrawLayer!(toolsLayer)
    end
end

function layersChanged(layers::Array{Ahorn.Layer, 1})
    wantedLayer = get(Ahorn.persistence, "placements_layer", "entities")

    global drawingLayers = layers
    global toolsLayer = Ahorn.getLayerByName(layers, "tools")
    global targetLayer = Ahorn.selectLayer!(layers, wantedLayer, "entities")
end

function applyTileSelectionBrush!(target::Ahorn.TileSelection, clear::Bool=false)
    Maple.updateTileSize!(relevantRoom, '0', '0')

    roomTiles = target.fg ? relevantRoom.fgTiles : relevantRoom.bgTiles
    tiles = clear ? fill('0', size(target.tiles)) : target.tiles

    x, y = floor(Int, target.selection.x / 8), floor(Int, target.selection.y / 8)
    brush = Ahorn.Brush(
        "Selection Finisher",
        clear ? fill(1, size(tiles) .- 2) : tiles[2:end - 1, 2:end - 1] .!= '0'
    )

    Ahorn.applyBrush!(brush, roomTiles, tiles[2:end - 1, 2:end - 1], x + 1, y + 1)
end

function afterUndo(map::Maple.Map)
    global selections = Ahorn.fixSelections(relevantRoom, selections)
    Ahorn.redrawLayer!(toolsLayer)
end

function afterRedo(map::Maple.Map)
    global selections = Ahorn.fixSelections(relevantRoom, selections)
    Ahorn.redrawLayer!(toolsLayer)
end

function finalizeSelections!(targets::Set{Ahorn.SelectedObject})
    shouldRedraw = false

    for selection in targets
        layer = selection.layerName

        if layer == "fgTiles" || layer == "bgTiles"
            applyTileSelectionBrush!(selection.target, false)
            shouldRedraw = true
        end
    end

    if shouldRedraw
        redrawTargetLayer!(targetLayer, targets)
    end
end

function initSelections!(targets::Set{Ahorn.SelectedObject})
    shouldRedraw = false

    for selection in targets
        layer = selection.layerName

        if layer == "fgTiles" || layer == "bgTiles"
            applyTileSelectionBrush!(selection.target, true)
            shouldRedraw = true
        end
    end

    if shouldRedraw
        redrawTargetLayer!(targetLayer, targets)
    end
end

function setSelections(map::Maple.Map, room::Maple.Room, newSelections::Set{Ahorn.SelectedObject})
    if room.name == relevantRoom.name
        empty!(selections)
        union!(selections, Ahorn.fixSelections(relevantRoom, newSelections))

        Ahorn.redrawLayer!(toolsLayer)
    end
end

function getSelections()
    return selections
end

function gridSnapped(v, step, direction)
    if direction == 0
        return v

    elseif direction > 0
        return v + step - mod(v, step)

    else
        return v - mod1(v, step)
    end
end

applyMovement!(target, ox, oy, node) = false

function applyMovement!(target::Union{Maple.Entity, Maple.Trigger}, ox, oy, node=0)
    if node == 0
        target.data["x"] += ox
        target.data["y"] += oy

    else
        nodes = get(target.data, "nodes", ())

        if length(nodes) >= node
            nodes[node] = nodes[node] .+ (ox, oy)
        end
    end

    return true
end

function applyMovement!(decal::Maple.Decal, ox, oy, node=0)
    decal.x += ox
    decal.y += oy

    return true
end

function applyMovement!(target::Ahorn.TileSelection, ox, oy, node=0)
    target.offsetX += ox
    target.offsetY += oy

    target.selection = Ahorn.Rectangle(target.startX + floor(target.offsetX / 8) * 8, target.startY + floor(target.offsetY / 8) * 8, target.selection.w, target.selection.h)

    return true
end

function applyGridMovement!(target::Union{Maple.Entity, Maple.Trigger}, gridSize, directionX, directionY, node=0)
    if node == 0
        x, y = target.data["x"], target.data["y"]
        ox, oy = gridSnapped(x, gridSize, directionX), gridSnapped(y, gridSize, directionY)

        applyMovement!(target, ox - x, oy - y, node)

    else
        nodes = get(target.data, "nodes", ())
        
        if length(nodes) >= node
            nx, ny = nodes[node]
            ox, oy = gridSnapped(nx, gridSize, directionX), gridSnapped(ny, gridSize, directionY)

            applyMovement!(target, ox - nx, oy - ny, node)
        end
    end
end

function applyGridMovement!(decal::Maple.Decal, gridSize, directionX, directionY, node=0)
    ox, oy = gridSnapped(decal.x, gridSize, directionX), gridSnapped(decal.y, gridSize, directionY)
    
    applyMovement!(decal, ox - decal.x, oy - decal.y)
end

function applyGridMovement!(target::Ahorn.TileSelection, gridSize, directionX, directionY, node=0)
    ox, oy = gridSnapped(target.offsetX, gridSize, directionX), gridSnapped(target.offsetY, gridSize, directionY)

    applyMovement!(target, ox - target.offsetX, oy - target.offsetY)
end


# Deprecated, now uses Ahorn.moved
# Getting removed in the future
function notifyMovement!(entity::Maple.Entity)
    Ahorn.eventToModules(Ahorn.loadedEntities, "moved", entity)
    Ahorn.eventToModules(Ahorn.loadedEntities, "moved", entity, relevantRoom)
end

function notifyMovement!(trigger::Maple.Trigger)
    Ahorn.eventToModules(Ahorn.loadedTriggers, "moved", trigger)
    Ahorn.eventToModules(Ahorn.loadedTriggers, "moved", trigger, relevantRoom)
end

# Decals and Tiles don't care
notifyMovement!(decal::Maple.Decal) = nothing
notifyMovement!(target::Ahorn.TileSelection) = nothing

mutable struct KeyboardHandleResults
    redraw::Bool
    clearDrag::Bool
    clearResize::Bool
    clearAreaOperation::Bool

    KeyboardHandleResults() = new(false, false, false, false)
end

resizeModifiers = Dict{Integer, Tuple{Number, Number}}(
    # w, h
    # Decrease / Increase width
    Int('q') => (1, 0),
    Int('e') => (-1, 0),

    # Decrease / Increase height
    Int('a') => (0, 1),
    Int('d') => (0, -1)
)

# (Key, steps clockwise)
rotationSteps = Dict{Integer, Integer}(
    Int('r') => 1,
    Int('l') => -1,
)

# (Key, steps clockwise)
rotationAreaSteps = Dict{Integer, Integer}(
    Int('R') => 1,
    Int('L') => -1,
)

addNodeKeys = [Int('n'), Int('+')]

# (Key code, horizontal flip)
flipDirections = Dict{Integer, Bool}(
    # Vertical Flip
    Int('v') => false,

    # Horizontal Flip
    Int('h') => true,
)

# (Key code, horizontal flip)
flipAreaDirections = Dict{Integer, Bool}(
    # Vertical Area Flip
    Int('V') => false,

    # Horizontal Area Flip
    Int('H') => true,
)

# Consider exposing the grid snap value
function handleMovement(results::KeyboardHandleResults, event::Ahorn.eventKey)
    handled = false

    step = Ahorn.modifierControl() ? 1 : 8
    snapMode = get(Ahorn.config, "use_grid_snapping", true)

    for selection in selections
        name, box, target, node = selection.layerName, selection.rectangle, selection.target, selection.node
        dirX, dirY = Ahorn.moveDirections[event.keyval]

        if snapMode
            if applyGridMovement!(target, step, dirX, dirY, node)
                notifyMovement!(target)

                Ahorn.moved(target)
                Ahorn.moved(target, step * dirX, step * dirY)

                handled = true
            end

        else
            redraw = applyMovement!(target, dirX * step, dirY * step, node)

            if redraw
                notifyMovement!(target)

                Ahorn.moved(target)
                Ahorn.moved(target, step * dirX, step * dirY)

                handled = true
            end
        end
    end

    if handled
        results.redraw = true
        results.clearDrag = true
        results.clearResize = true
        results.clearAreaOperation = true
    end
end

function handleResize(results::KeyboardHandleResults, event::Ahorn.eventKey)
    handled = false
    step = Ahorn.modifierControl() ? 1 : 8

    processed = Set{Union{Maple.Entity, Maple.Trigger}}()
    snapMode = get(Ahorn.config, "use_grid_snapping", true)

    for selection in selections
        name, box, target, node = selection.layerName, selection.rectangle, selection.target, selection.node
        dirW, dirH = resizeModifiers[event.keyval]

        if (name == "entities" || name == "triggers") && !(target in processed)
            horizontal, vertical = Ahorn.canResizeWrapper(target)
            minWidth, minHeight = Ahorn.minimumSizeWrapper(target)

            baseWidth = get(target, "width", minWidth)
            baseHeight = get(target, "height", minHeight)

            newWidth = snapMode ? max(gridSnapped(baseWidth, step, dirW), minWidth) : max(baseWidth + dirW * step, minWidth)
            newHeight = snapMode ? max(gridSnapped(baseHeight, step, dirH), minHeight) : max(baseHeight + dirH * step, minHeight)

            if horizontal
                target.width = newWidth
            end

            if vertical
                target.height = newHeight
            end

            Ahorn.resized(target)

            handled = true

            push!(processed, target)

        elseif name == "fgDecals" || name == "bgDecals"
            extraW, extraH = resizeModifiers[event.keyval]
            minVal, maxVal = decalScaleVals

            target.scaleX = sign(target.scaleX) * clamp(abs(target.scaleX) * 2.0^extraW, minVal, maxVal)
            target.scaleY = sign(target.scaleY) * clamp(abs(target.scaleY) * 2.0^extraH, minVal, maxVal)

            handled = true
        end
    end

    if handled
        results.redraw = true
        results.clearAreaOperation = true
        results.clearResize = true
    end
end

function handleFlipping!(selected::Ahorn.SelectedObject, target::Ahorn.Decal, horizontal::Bool)
    Ahorn.flipped(target, horizontal)

    return true
end

function handleFlipping!(selected::Ahorn.SelectedObject, target::Ahorn.TileSelection, horizontal::Bool)
    Ahorn.flipped(target, horizontal)

    return true
end

function handleFlipping!(selected::Ahorn.SelectedObject, target::Union{Ahorn.Entity, Ahorn.Trigger}, horizontal::Bool)
    if selected.node == 0
        flipped = Ahorn.flipped(target, horizontal)

        if flipped !== nothing
            selected.rectangle = Ahorn.getSelection(flipped, relevantRoom, 0)
            selected.target = flipped

            targets = selected.layerName == "entities" ? relevantRoom.entities : relevantRoom.triggers
            index = findfirst(==(target), targets)

            # Some entities can just change their attributes
            if index !== nothing
                deleteat!(targets, index)
                insert!(targets, index, flipped)
            end

            return true
        end
    end

    return false
end

function handleAreaFlipping!(selected::Ahorn.SelectedObject, target::Ahorn.Decal, horizontal::Bool, area::Ahorn.Rectangle)
    Ahorn.flipped(target, horizontal)

    if horizontal
        target.x = 2 * area.x + area.w - target.x

    else
        target.y = 2 * area.y + area.h - target.y
    end

    return true
end

function handleAreaFlipping!(selected::Ahorn.SelectedObject, target::Ahorn.TileSelection, horizontal::Bool, area::Ahorn.Rectangle)
    Ahorn.flipped(target, horizontal)

    if horizontal
        target.offsetX = 2 * area.x + area.w - target.selection.x - target.selection.w - target.startX

    else
        target.offsetY = 2 * area.y + area.h - target.selection.y - target.selection.h - target.startY
    end

    target.selection = Ahorn.Rectangle(target.startX + div(target.offsetX, 8) * 8, target.startY + div(target.offsetY, 8) * 8, target.selection.w, target.selection.h)

    return true
end

function handleAreaFlipping!(selected::Ahorn.SelectedObject, target::Union{Ahorn.Entity, Ahorn.Trigger}, horizontal::Bool, area::Ahorn.Rectangle)
    # handleFlipping updates the target in selected to the correct target
    # The passed target arugment is only for multiple dispatch

    handleFlipping!(selected, target, horizontal)

    width = get(target, "width", 0)
    height = get(target, "height", 0)

    if selected.node == 0
        if horizontal
            selected.target.x = 2 * area.x + area.w - width - selected.target.x

        else
            selected.target.y = 2 * area.y + area.h - height - selected.target.y
        end

    else
        x, y = selected.target.nodes[selected.node]

        if horizontal
            x = 2 * area.x + area.w - width - x

        else
            y = 2 * area.y + area.h - height - y
        end

        selected.target.nodes[selected.node] = (x, y)
    end

    return true
end

function handleFlipping(results::KeyboardHandleResults, event::Ahorn.eventKey)
    horizontal = flipDirections[event.keyval]

    for selection in selections
        results.redraw |= handleFlipping!(selection, selection.target, horizontal)
    end

    results.clearAreaOperation |= results.redraw
end

function handleAreaFlipping(results::KeyboardHandleResults, event::Ahorn.eventKey)
    selectionRectangle = getSelectionArea()
    area = updateAreaOperationRectangle!(selectionRectangle)
    horizontal = flipAreaDirections[event.keyval]

    for selection in selections
        results.redraw |= handleAreaFlipping!(selection, selection.target, horizontal, area)
    end
end

function handleRotation!(selected::Ahorn.SelectedObject, target::Ahorn.TileSelection, steps::Int)
    selected.target = Ahorn.rotated(target, steps)
    selected.rectangle = target.selection

    return true
end

handleRotation!(selected::Ahorn.SelectedObject, target::Ahorn.Decal, steps::Int) = false

function handleRotation!(selected::Ahorn.SelectedObject, target::Union{Ahorn.Entity, Ahorn.Trigger}, steps::Int)
    if selected.node == 0
        rotated = Ahorn.rotated(target, steps)

        if rotated !== nothing
            selected.rectangle = Ahorn.getSelection(rotated, relevantRoom, 0)
            selected.target = rotated

            targets = selected.layerName == "entities" ? relevantRoom.entities : relevantRoom.triggers
            index = findfirst(==(target), targets)

            # Some entities can just change their attributes
            if index !== nothing
                deleteat!(targets, index)
                insert!(targets, index, rotated)
            end

            return true
        end
    end

    return false
end

function handleRotation(results::KeyboardHandleResults, event::Ahorn.eventKey)
    steps = rotationSteps[event.keyval]

    for selection in selections
        results.redraw |= handleRotation!(selection, selection.target, steps)
    end

    results.clearAreaOperation |= results.redraw
end

function handleAreaRotation(results::KeyboardHandleResults, event::Ahorn.eventKey)
    # TODO - Implement
    # Seems super niche compared to area flipping

    return false
end

function handleAddNodes(results::KeyboardHandleResults, event::Ahorn.eventKey)
    for selection in selections
        name, box, target, node = selection.layerName, selection.rectangle, selection.target, selection.node

        if name == "entities" || name == "triggers"
            least, most = Ahorn.nodeLimits(target)
            nodes = get(target.data, "nodes", Tuple{Int, Int}[])

            if most == -1 || length(nodes) + 1 <= most
                x, y = target.data["x"], target.data["y"]

                if node > 0
                    x, y = nodes[node]
                end

                insert!(nodes, node + 1, (x + 16, y))
                results.redraw = true

                target.data["nodes"] = nodes
            end
        end
    end
end

handleDeletion(selections::Set{Ahorn.SelectedObject}) = handleDeletion(KeyboardHandleResults(), selections)

function handleDeletion(results::KeyboardHandleResults, selections::Set{Ahorn.SelectedObject})
    results.redraw |= !isempty(selections)
    results.clearAreaOperation |= results.redraw

    selectionsArray = collect(selections)

    # Split into different arrays
    tileSelections = filter(s -> s.layerName == "bgTiles" || s.layerName == "fgTiles", selectionsArray)
    entityTriggerSelections = filter(s -> s.layerName == "entities" || s.layerName == "triggers", selectionsArray)
    decalSelections = filter(s -> s.layerName == "bgDecals" || s.layerName == "fgDecals", selectionsArray)

    # Sort entities, otherwise deletion will break with nodes
    sort!(entityTriggerSelections, by=r -> (r.target.id, r.node), rev=true)

    # Deletion for entities and triggers
    for selection in entityTriggerSelections
        name, box, target, node = selection.layerName, selection.rectangle, selection.target, selection.node
        targetList = Ahorn.selectionTargets[name](relevantRoom)

        index = findfirst(isequal(target), targetList)
        if index !== nothing
            if node == 0
                deleteat!(targetList, index)

            else
                least, most = Ahorn.nodeLimits(target)
                nodes = get(target.data, "nodes", [])

                # Delete the node if that doesn't result in too few nodes
                # Delete the whole entity if it does
                if length(nodes) - 1 >= least && length(nodes) >= node
                    deleteat!(nodes, node)

                else
                    deleteat!(targetList, index)
                end
            end

            Ahorn.deleted(target, node)
        end
    end

    # Deletion for decals
    for selection in decalSelections
        targetList = Ahorn.selectionTargets[selection.layerName](relevantRoom)

        index = findfirst(isequal(selection.target), targetList)
        if index !== nothing
            deleteat!(targetList, index)
        end
    end

    # Tiles are deleted by removing them from the set, no special handle

    if !isempty(selections)
        empty!(selections)
    end
end

function handleClearSelections(results::KeyboardHandleResults)
    clearSelections!()

    results.redraw = true
end

# Refactor and prettify code once we know how to handle tiles here,
# this also includes the handle functions
function keyboard(event::Ahorn.eventKey)
    results = KeyboardHandleResults()

    layersSelected = getLayersSelected(selections)
    snapshot = Ahorn.History.MultiSnapshot("Selections", Ahorn.History.Snapshot[
        Ahorn.History.RoomSnapshot("Selections", Ahorn.loadedState.room),
        Ahorn.History.SelectionSnapshot("Selections", relevantRoom, selections)
    ])

    results.redraw |= Ahorn.callbackFirstActive(hotkeys, event)

    if haskey(Ahorn.moveDirections, event.keyval)
        handleMovement(results, event)
    end

    if haskey(resizeModifiers, event.keyval)
        handleResize(results, event)
    end

    if haskey(flipDirections, event.keyval) && !Ahorn.modifierControl()
        handleFlipping(results, event)
    end

    if haskey(flipAreaDirections, event.keyval) && !Ahorn.modifierControl()
        handleAreaFlipping(results, event)
    end

    if haskey(rotationSteps, event.keyval) && !Ahorn.modifierControl()
        handleRotation(results, event)
    end

    if haskey(rotationAreaSteps, event.keyval) && !Ahorn.modifierControl()
        handleAreaRotation(results, event)
    end

    if event.keyval in addNodeKeys && !Ahorn.modifierControl()
        handleAddNodes(results, event)
    end

    if event.keyval == Ahorn.Gtk.GdkKeySyms.Delete && !Ahorn.modifierControl()
        handleDeletion(results, selections)
    end

    if event.keyval == Ahorn.Gtk.GdkKeySyms.Return || event.keyval == Ahorn.Gtk.GdkKeySyms.Escape
        handleClearSelections(results)
    end

    # Actions based on results from events
    if results.clearDrag
        clearDragging!()
    end

    if results.clearResize
        clearResize!()
    end

    if results.clearAreaOperation
        clearAreaOperationRectangle!()
    end

    if results.redraw
        toolsLayer.redraw = true
        redrawTargetLayer!(targetLayer, layersSelected)

        Ahorn.History.addSnapshot!(snapshot)

        # Send a fake event to clear up visuals
        mouseMotionAbs(lastX, lastY)
    end

    return true
end

end