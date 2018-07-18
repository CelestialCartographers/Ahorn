module Selection

displayName = "Selection"
group = "Placements"

drawingLayers = Main.Layer[]

toolsLayer = nothing
targetLayer = nothing

# Drag selection, track individually for easy replacement
selectionRect = Main.Rectangle(0, 0, 0, 0)
selections = Set{Tuple{String, Main.Rectangle, Any, Number}}()

lastX, lastY = -1, -1
shouldDrag = false

decalScaleVals = (1.0, 2.0^4)

relevantRoom = Main.loadedState.room
selectionsClipboard = Set{Tuple{String, Main.Rectangle, Any, Number}}()

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

    redrawTargetLayer!(targetLayer, selectionsClipboard)
    Main.redrawLayer!(toolsLayer)

    return cut
end

cutSelections() = copySelections(true)

function pasteSelections()
    if isempty(selectionsClipboard)
       return false
    end

    newSelections = deepcopy(selectionsClipboard)
    room = relevantRoom

    for selection in newSelections
        layer, box, target, node = selection

        if layer == "fgDecals"
            push!(room.fgDecals, target)

        elseif layer == "bgDecals"
            push!(room.bgDecals, target)

        elseif layer == "entities" && node == 0
            target.id = Main.Maple.nextEntityId()

            push!(room.entities, target)

        elseif layer == "triggers" && node == 0
            target.id = Main.Maple.nextTriggerId()

            push!(room.triggers, target)
        end
    end

    finalizeSelections!(selections)
    empty!(selections)
    union!(selections, newSelections)

    redrawTargetLayer!(targetLayer, selections)
    Main.redrawLayer!(toolsLayer)

    return true
end

hotkeys = Main.Hotkey[
    Main.Hotkey(
        'c',
        copySelections,
        Function[
            Main.modifierControl
        ]
    ),
    Main.Hotkey(
        'x',
        cutSelections,
        Function[
            Main.modifierControl
        ]
    ),
    Main.Hotkey(
        'v',
        pasteSelections,
        Function[
            Main.modifierControl,
        ]
    )
]

function drawSelections(layer::Main.Layer, room::Main.Room)
    drawnTargets = Set()
    ctx = Main.creategc(toolsLayer.surface)

    if selectionRect !== nothing && selectionRect.w > 0 && selectionRect.h > 0 && !shouldDrag
        Main.drawRectangle(ctx, selectionRect, Main.colors.selection_selection_fc, Main.colors.selection_selection_bc)
    end

    # Make sure fgTiles render after the bgTiles
    # Looks better, shouldn't cost to much performance
    selectionsArray = collect(selections)
    sort!(selectionsArray, by=r -> r[1])

    for selection in selectionsArray
        layer, box, target, node = selection

        if isa(target, Main.Maple.Entity) && !(target in drawnTargets)
            Main.renderEntitySelection(ctx, toolsLayer, target, relevantRoom)

            push!(drawnTargets, target)
        end

        if isa(target, Main.TileSelection)
            Main.drawFakeTiles(ctx, relevantRoom, target.tiles, target.fg, target.selection.x, target.selection.y, clipEdges=true)
        end

        # Get a new selection rectangle
        # This is easier than editing the existing rect
        success, rect = Main.getSelection(target)
        if isa(rect, Array{Main.Rectangle}) && length(rect) >= node + 1
            Main.drawRectangle(ctx, rect[node + 1], Main.colors.selection_selected_fc, Main.colors.selection_selected_bc)

        else
            Main.drawRectangle(ctx, rect, Main.colors.selection_selected_fc, Main.colors.selection_selected_bc)
        end
    end

    return true
end

function clearDragging!()
    global lastX = -1
    global lastY = -1
    global shouldDrag = false
end

function cleanup()
    finalizeSelections!(selections)
    empty!(selections)

    global selectionRect = nothing
    global relevantRoom = Main.loadedState.room

    clearDragging!()

    Main.redrawLayer!(toolsLayer)
end

function toolSelected(subTools::Main.ListContainer, layers::Main.ListContainer, materials::Main.ListContainer)
    global relevantRoom = Main.loadedState.room
    
    wantedLayer = get(Main.persistence, "placements_layer", "entities")
    Main.updateLayerList!(vcat(["all"], Main.selectableLayers), row -> row[1] == Main.layerName(targetLayer))

    Main.redrawingFuncs["tools"] = drawSelections
    Main.redrawLayer!(toolsLayer)
end

function layerSelected(list::Main.ListContainer, materials::Main.ListContainer, selected::String)
    global targetLayer = Main.getLayerByName(drawingLayers, selected)
    Main.persistence["placements_layer"] = selected
end

function selectionMotionAbs(rect::Main.Rectangle)
    if rect != selectionRect
        global selectionRect = rect

        Main.redrawLayer!(toolsLayer)
    end
end

function selectionMotionAbs(x1::Number, y1::Number, x2::Number, y2::Number)
    if lastX == -1 || lastY == -1
        ctrl = Main.modifierControl()

        global lastX = ctrl? x1 : div(x1, 8) * 8
        global lastY = ctrl? y1 : div(y1, 8) * 8

        if !shouldDrag
            success, target = Main.hasSelectionAt(selections, Main.Rectangle(x1, y1, 1, 1))
            global shouldDrag = success

            if success
                Main.History.addSnapshot!(Main.History.MultiSnapshot("Selections", Main.History.Snapshot[
                    Main.History.RoomSnapshot("Selections", Main.loadedState.room),
                    Main.History.SelectionSnapshot("Selections", relevantRoom, selections)
                ]))
            end
        end
    end

    if shouldDrag
        if !Main.modifierControl()
            x1 = div(x1, 8) * 8
            y1 = div(y1, 8) * 8

            x2 = div(x2, 8) * 8
            y2 = div(y2, 8) * 8
        end

        dx = x2 - lastX
        dy = y2 - lastY

        global lastX = x2
        global lastY = y2

        if dx != 0 || dy != 0
            for selection in selections
                layer, box, target, node = selection

                if applicable(applyMovement!, target, dx, dy, node)
                    applyMovement!(target, dx, dy, node)
                    notifyMovement!(target)
                end
            end

            Main.redrawLayer!(toolsLayer)
            redrawTargetLayer!(targetLayer, selections, String["fgTiles", "bgTiles"])
        end
    end
end

function properlyUpdateSelections!(rect::Main.Rectangle, selections::Set{Tuple{String, Main.Rectangle, Any, Number}}; best::Bool=false)
    retain = Main.modifierShift()

    # Do this before we get new selections
    # This way tiles are settled back into place before we select
    if !retain
        finalizeSelections!(selections)
    end

    unselected, newlySelected = Main.updateSelections!(selections, relevantRoom, Main.layerName(targetLayer), rect, retain=retain, best=best)
    initSelections!(newlySelected)
end

function getLayersSelected(selections::Set{Tuple{String, Main.Rectangle, Any, Number}})
    return unique([selection[1] for selection in selections])
end

function redrawTargetLayer!(layer::Main.Layer, selections::Set{Tuple{String, Main.Rectangle, Any, Number}}, ignore::Array{String, 1}=String[])
    redrawTargetLayer!(layer, getLayersSelected(selections), ignore)
end

function redrawTargetLayer!(layer::Main.Layer, layers::Array{String, 1}, ignore::Array{String, 1}=String[])
    needsRedraw = filter(v -> !(v in ignore), layers)

    for layer in needsRedraw
        Main.redrawLayer!(drawingLayers, layer)
    end
end

function selectionFinishAbs(rect::Main.Rectangle)
    # If we are draging we are techically not making a new selection
    if !shouldDrag
        properlyUpdateSelections!(rect, selections)
    end

    clearDragging!()

    global selectionRect = Main.Rectangle(0, 0, 0, 0)

    Main.redrawLayer!(toolsLayer)
end

function leftClickAbs(x::Number, y::Number)
    rect = Main.Rectangle(x, y, 1, 1)
    properlyUpdateSelections!(rect, selections, best=true)

    clearDragging!()

    Main.redrawLayer!(toolsLayer)
end

function rightClickAbs(x::Number, y::Number)
    Main.displayProperties(x, y, relevantRoom, targetLayer)

    clearDragging!()

    Main.redrawLayer!(toolsLayer)        
end

function layersChanged(layers::Array{Main.Layer, 1})
    wantedLayer = get(Main.persistence, "placements_layer", "entities")

    global drawingLayers = layers
    global toolsLayer = Main.getLayerByName(layers, "tools")
    global targetLayer = Main.selectLayer!(layers, wantedLayer, "entities")
end

function applyTileSelecitonBrush!(target::Main.TileSelection, clear::Bool=false)
    roomTiles = target.fg? relevantRoom.fgTiles : relevantRoom.bgTiles
    tiles = clear? fill('0', size(target.tiles)) : target.tiles

    x, y = floor(Int, target.selection.x / 8), floor(Int, target.selection.y / 8)
    brush = Main.Brush(
        "Selection Finisher",
        clear? fill(1, size(tiles) .- 2) : tiles[2:end - 1, 2:end - 1] .!= '0'
    )

    Main.applyBrush!(brush, roomTiles, tiles[2:end - 1, 2:end - 1], x + 1, y + 1)
end

function afterUndo(map::Main.Maple.Map)
    global selections = Main.fixSelections(relevantRoom, selections)
    Main.redrawLayer!(toolsLayer)
end

function afterRedo(map::Main.Maple.Map)
    global selections = Main.fixSelections(relevantRoom, selections)
    Main.redrawLayer!(toolsLayer)
end

function finalizeSelections!(targets::Set{Tuple{String, Main.Rectangle, Any, Number}})
    for selection in targets
        layer, box, target, node = selection

        if layer == "fgTiles" || layer == "bgTiles"
            applyTileSelecitonBrush!(target, false)
        end
    end

    if !isempty(targets)
        redrawTargetLayer!(targetLayer, targets)
    end
end

function initSelections!(targets::Set{Tuple{String, Main.Rectangle, Any, Number}})
    for selection in targets
        layer, box, target, node = selection

        if layer == "fgTiles" || layer == "bgTiles"
            applyTileSelecitonBrush!(target, true)
        end
    end

    if !isempty(targets)
        redrawTargetLayer!(targetLayer, targets)
    end
end

function setSelections(map::Main.Maple.Map, room::Main.Maple.Room, newSelections::Set{Tuple{String, Main.Rectangle, Any, Number}})
    if room.name == relevantRoom.name
        empty!(selections)
        union!(selections, Main.fixSelections(relevantRoom, newSelections))

        Main.redrawLayer!(toolsLayer)
    end
end

function getSelections()
    return true, selections
end

function applyMovement!(target::Union{Main.Maple.Entity, Main.Maple.Trigger}, ox::Number, oy::Number, node::Number=0)
    if node == 0
        target.data["x"] += ox
        target.data["y"] += oy

    else
        nodes = get(target.data, "nodes", ())

        if length(nodes) >= node
            nodes[node] = nodes[node] .+ (ox, oy)
        end
    end
end

function applyMovement!(decal::Main.Maple.Decal, ox::Number, oy::Number, node::Number=0)
    decal.x += ox
    decal.y += oy
end

function applyMovement!(target::Main.TileSelection, ox::Number, oy::Number, node::Number=0)
    target.offsetX += ox
    target.offsetY += oy

    target.selection = Main.Rectangle(target.startX + floor(target.offsetX / 8) * 8, target.startY + floor(target.offsetY / 8) * 8, target.selection.w, target.selection.h)
end

function notifyMovement!(entity::Main.Maple.Entity)
    Main.eventToModules(Main.loadedEntities, "moved", entity)
    Main.eventToModules(Main.loadedEntities, "moved", entity, relevantRoom)
end

function notifyMovement!(trigger::Main.Maple.Trigger)
    Main.eventToModules(Main.loadedTriggers, "moved", trigger)
    Main.eventToModules(Main.loadedTriggers, "moved", trigger, relevantRoom)
end

function notifyMovement!(decal::Main.Maple.Decal)
    # Decals doesn't care
end

function notifyMovement!(target::Main.TileSelection)
    # Decals doesn't care
end

resizeModifiers = Dict{Integer, Tuple{Number, Number}}(
    # w, h
    # Decrease / Increase width
    Int('q') => (1, 0),
    Int('w') => (-1, 0),

    # Decrease / Increase height
    Int('a') => (0, 1),
    Int('s') => (0, -1)
)

addNodeKey = Int('n')

# Turns out having scales besides -1 and 1 on decals causes weird behaviour?
scaleMultipliers = Dict{Integer, Tuple{Number, Number}}(
    # Vertical Flip
    Int('v') => (1, -1),

    # Horizontal Flip
    Int('h') => (-1, 1),
)

function handleMovement(event::Main.eventKey)
    redraw = false
    step = Main.modifierControl()? 1 : 8

    for selection in selections
        name, box, target, node = selection
        ox, oy = Main.moveDirections[event.keyval] .* step

        if applicable(applyMovement!, target, ox, oy, node)
            applyMovement!(target, ox, oy, node)
            notifyMovement!(target)

            redraw = true
        end
    end

    return redraw
end

function handleResize(event::Main.eventKey)
    redraw = false
    step = Main.modifierControl()? 1 : 8

    for selection in selections
        name, box, target, node = selection
        extraW, extraH = resizeModifiers[event.keyval] .* step

        if (name == "entities" || name == "triggers") && node == 0
            horizontal, vertical = Main.canResize(target)
            minWidth, minHeight = Main.minimumSize(target)

            baseWidth = get(target.data, "width", minWidth)
            baseHeight = get(target.data, "height", minHeight)

            width = horizontal? (max(baseWidth + extraW, minWidth)) : baseWidth
            height = vertical? (max(baseHeight + extraH, minHeight)) : baseHeight

            target.data["width"] = width
            target.data["height"] = height

            redraw = true

        elseif name == "fgDecals" || name == "bgDecals"
            extraW, extraH = resizeModifiers[event.keyval]
            minVal, maxVal = decalScaleVals
            
            # Ready for when decals render correctly
            #target.scaleX = sign(target.scaleX) * clamp(abs(target.scaleX) * 2.0^extraW, minVal, maxVal)
            #target.scaleY = sign(target.scaleY) * clamp(abs(target.scaleY) * 2.0^extraH, minVal, maxVal)

            redraw = true
        end
    end

    return redraw
end

function handleScaling(event::Main.eventKey)
    redraw = false
    for selection in selections
        name, box, target, node = selection
        msx, msy = scaleMultipliers[event.keyval]

        if isa(target, Main.Maple.Decal)
            target.scaleX *= msx
            target.scaleY *= msy

            redraw = true
        end
    end

    return redraw
end

function handleAddNodes(event::Main.eventKey)
    redraw = false

    for selection in selections
        name, box, target, node = selection

        if name == "entities"
            least, most = Main.nodeLimits(target)
            nodes = get(target.data, "nodes", [])

            if most == -1 || length(nodes) + 1 <= most
                x, y = target.data["x"], target.data["y"]

                if node > 0
                    x, y = nodes[node]
                end

                insert!(nodes, node + 1, (x + 16, y))
                redraw = true

                target.data["nodes"] = nodes
            end
        end
    end

    return redraw
end

function handleDeletion(selections::Set{Tuple{String, Main.Rectangle, Any, Number}})
    res = !isempty(selections)
    selectionsArray = collect(selections)

    # Split into different arrays
    tileSelections = filter(s -> s[1] == "bgTiles" || s[1] == "fgTiles", selectionsArray)
    entityTriggerSelections = filter(s -> s[1] == "entities" || s[1] == "triggers", selectionsArray)
    decalSelections = filter(s -> s[1] == "bgDecals" || s[1] == "fgDecals", selectionsArray)

    # Sort entities, otherwise deletion will break with nodes
    sort!(entityTriggerSelections, by=r -> (r[3].id, r[4]), rev=true)

    # Deletion for entities and triggers
    for selection in entityTriggerSelections
        name, box, target, node = selection
        targetList = Main.selectionTargets[name](relevantRoom)

        index = findfirst(targetList, target)
        if index != 0 
            if node == 0
                deleteat!(targetList, index)

            else
                least, most = Main.nodeLimits(target)
                nodes = get(target.data, "nodes", [])

                # Delete the node if that doesn't result in too few nodes
                # Delete the whole entity if it does
                if length(nodes) - 1 >= least && length(nodes) >= node
                    deleteat!(nodes, node)

                else
                    deleteat!(targetList, index)
                end
            end
        end
    end

    # Deletion for decals
    for selection in decalSelections    
        name, box, target, node = selection
        targetList = Main.selectionTargets[name](relevantRoom)

        index = findfirst(targetList, target)
        if index != 0 
            deleteat!(targetList, index)
        end
    end

    # Tiles are deleted by removing them from the set, no special handle

    if !isempty(selections)
        empty!(selections)
    end

    return res
end

# Refactor and prettify code once we know how to handle tiles here,
# this also includes the handle functions
function keyboard(event::Main.eventKey)
    needsRedraw = false
    layersSelected = getLayersSelected(selections)
    snapshot = Main.History.MultiSnapshot("Selections", Main.History.Snapshot[
        Main.History.RoomSnapshot("Selections", Main.loadedState.room),
        Main.History.SelectionSnapshot("Selections", relevantRoom, selections)
    ])

    for hotkey in hotkeys
        if Main.active(hotkey, event)
            needsRedraw |= Main.callback(hotkey)
        end
    end

    if haskey(Main.moveDirections, event.keyval)
        needsRedraw |= handleMovement(event)
    end

    if haskey(resizeModifiers, event.keyval)
        needsRedraw |= handleResize(event)
    end

    if haskey(scaleMultipliers, event.keyval) && !Main.modifierControl()
        needsRedraw |= handleScaling(event)
    end

    if event.keyval == addNodeKey && !Main.modifierControl()
        needsRedraw |= handleAddNodes(event)
    end

    if event.keyval == Main.Gtk.GdkKeySyms.Delete && !Main.modifierControl()
        needsRedraw |= handleDeletion(selections)
    end

    if needsRedraw
        Main.History.addSnapshot!(snapshot)
        Main.redrawLayer!(toolsLayer)
        redrawTargetLayer!(targetLayer, layersSelected)
    end

    return true
end

end