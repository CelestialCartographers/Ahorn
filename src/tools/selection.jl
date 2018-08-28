module Selection

using ..Ahorn

displayName = "Selection"
group = "Placements"

drawingLayers = Ahorn.Layer[]

toolsLayer = nothing
targetLayer = nothing

# Drag selection, track individually for easy replacement
selectionRect = Ahorn.Rectangle(0, 0, 0, 0)
selections = Set{Tuple{String, Ahorn.Rectangle, Any, Number}}()

lastX, lastY = -1, -1
shouldDrag = false

decalScaleVals = (1.0, 2.0^4)

relevantRoom = Ahorn.loadedState.room
selectionsClipboard = Set{Tuple{String, Ahorn.Rectangle, Any, Number}}()

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
    Ahorn.redrawLayer!(toolsLayer)

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
            target.id = Ahorn.Maple.nextEntityId()

            push!(room.entities, target)

        elseif layer == "triggers" && node == 0
            target.id = Ahorn.Maple.nextTriggerId()

            push!(room.triggers, target)
        end
    end

    finalizeSelections!(selections)
    empty!(selections)
    union!(selections, newSelections)

    redrawTargetLayer!(targetLayer, selections)
    Ahorn.redrawLayer!(toolsLayer)

    return true
end

hotkeys = Ahorn.Hotkey[
    Ahorn.Hotkey(
        'c',
        copySelections,
        Function[
            Ahorn.modifierControl
        ]
    ),
    Ahorn.Hotkey(
        'x',
        cutSelections,
        Function[
            Ahorn.modifierControl
        ]
    ),
    Ahorn.Hotkey(
        'v',
        pasteSelections,
        Function[
            Ahorn.modifierControl,
        ]
    )
]

function drawSelections(layer::Ahorn.Layer, room::Ahorn.Room)
    drawnTargets = Set()
    ctx = Ahorn.creategc(toolsLayer.surface)

    if selectionRect !== nothing && selectionRect.w > 0 && selectionRect.h > 0 && !shouldDrag
        Ahorn.drawRectangle(ctx, selectionRect, Ahorn.colors.selection_selection_fc, Ahorn.colors.selection_selection_bc)
    end

    # Make sure fgTiles render after the bgTiles
    # Looks better, shouldn't cost to much performance
    selectionsArray = collect(selections)
    sort!(selectionsArray, by=r -> r[1])

    for selection in selectionsArray
        layer, box, target, node = selection

        if isa(target, Ahorn.Maple.Entity) && !(target in drawnTargets)
            Ahorn.renderEntitySelection(ctx, toolsLayer, target, relevantRoom)

            push!(drawnTargets, target)
        end

        if isa(target, Ahorn.Maple.Trigger) && !(target in drawnTargets)
            Ahorn.renderTriggerSelection(ctx, toolsLayer, target, relevantRoom)

            push!(drawnTargets, target)
        end

        if isa(target, Ahorn.TileSelection)
            Ahorn.drawFakeTiles(ctx, relevantRoom, target.tiles, target.fg, target.selection.x, target.selection.y, clipEdges=true)
        end

        # Get a new selection rectangle
        # This is easier than editing the existing rect
        success, rect = Ahorn.getSelection(target)
        if isa(rect, Array{Ahorn.Rectangle}) && length(rect) >= node + 1
            Ahorn.drawRectangle(ctx, rect[node + 1], Ahorn.colors.selection_selected_fc, Ahorn.colors.selection_selected_bc)

        else
            Ahorn.drawRectangle(ctx, rect, Ahorn.colors.selection_selected_fc, Ahorn.colors.selection_selected_bc)
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
    global relevantRoom = Ahorn.loadedState.room

    clearDragging!()

    Ahorn.redrawLayer!(toolsLayer)
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

function selectionMotionAbs(rect::Ahorn.Rectangle)
    if rect != selectionRect
        global selectionRect = rect

        Ahorn.redrawLayer!(toolsLayer)
    end
end

function selectionMotionAbs(x1::Number, y1::Number, x2::Number, y2::Number)
    if lastX == -1 || lastY == -1
        ctrl = Ahorn.modifierControl()

        global lastX = ctrl? x1 : div(x1, 8) * 8
        global lastY = ctrl? y1 : div(y1, 8) * 8

        if !shouldDrag
            success, target = Ahorn.hasSelectionAt(selections, Ahorn.Rectangle(x1, y1, 1, 1))
            global shouldDrag = success

            if success
                Ahorn.History.addSnapshot!(Ahorn.History.MultiSnapshot("Selections", Ahorn.History.Snapshot[
                    Ahorn.History.RoomSnapshot("Selections", Ahorn.loadedState.room),
                    Ahorn.History.SelectionSnapshot("Selections", relevantRoom, selections)
                ]))
            end
        end
    end

    if shouldDrag
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

        if dx != 0 || dy != 0
            for selection in selections
                layer, box, target, node = selection

                if applicable(applyMovement!, target, dx, dy, node)
                    applyMovement!(target, dx, dy, node)
                    notifyMovement!(target)
                end
            end

            Ahorn.redrawLayer!(toolsLayer)
            redrawTargetLayer!(targetLayer, selections, String["fgTiles", "bgTiles"])
        end
    end
end

function properlyUpdateSelections!(rect::Ahorn.Rectangle, selections::Set{Tuple{String, Ahorn.Rectangle, Any, Number}}; best::Bool=false, mass::Bool=false)
    retain = Ahorn.modifierShift()

    # Do this before we get new selections
    # This way tiles are settled back into place before we select
    if !retain
        finalizeSelections!(selections)
    end

    unselected, newlySelected = Ahorn.updateSelections!(selections, relevantRoom, Ahorn.layerName(targetLayer), rect, retain=retain, best=best, mass=mass)
    initSelections!(newlySelected)
end

function properlyMassSelection!(selections::Set{Tuple{String, Ahorn.Rectangle, Any, Number}}, rect::Ahorn.Rectangle; strict::Bool=false)
    retain = Ahorn.modifierShift()

    # Do this before we get new selections
    # This way tiles are settled back into place before we select
    if !retain
        finalizeSelections!(selections)
    end

    unselected, newlySelected = Ahorn.updateSelections!(selections, relevantRoom, Ahorn.layerName(targetLayer), rect, retain=retain, best=strict, mass=true)
    initSelections!(newlySelected)
end

function getLayersSelected(selections::Set{Tuple{String, Ahorn.Rectangle, Any, Number}})
    return unique([selection[1] for selection in selections])
end

function redrawTargetLayer!(layer::Ahorn.Layer, selections::Set{Tuple{String, Ahorn.Rectangle, Any, Number}}, ignore::Array{String, 1}=String[])
    redrawTargetLayer!(layer, getLayersSelected(selections), ignore)
end

function redrawTargetLayer!(layer::Ahorn.Layer, layers::Array{String, 1}, ignore::Array{String, 1}=String[])
    needsRedraw = filter(v -> !(v in ignore), layers)

    for layer in needsRedraw
        Ahorn.redrawLayer!(drawingLayers, layer)
    end
end

function selectionFinishAbs(rect::Ahorn.Rectangle)
    # If we are draging we are techically not making a new selection
    if !shouldDrag
        properlyUpdateSelections!(rect, selections)
    end

    clearDragging!()

    global selectionRect = Ahorn.Rectangle(0, 0, 0, 0)

    Ahorn.redrawLayer!(toolsLayer)
end

function leftClickAbs(x::Number, y::Number)
    rect = Ahorn.Rectangle(x, y, 1, 1)
    properlyUpdateSelections!(rect, selections, best=true)

    clearDragging!()

    Ahorn.redrawLayer!(toolsLayer)
end

function doubleLeftClickAbs(x::Number, y::Number)
    strict = Ahorn.modifierControl()
    rect = Ahorn.Rectangle(x, y, 1, 1)
    properlyMassSelection!(selections, rect, strict=strict)

    clearDragging!()

    Ahorn.redrawLayer!(toolsLayer)
end

function rightClickAbs(x::Number, y::Number)
    Ahorn.displayProperties(x, y, relevantRoom, targetLayer, toolsLayer, selections)

    clearDragging!()

    Ahorn.redrawLayer!(toolsLayer)
end

function layersChanged(layers::Array{Ahorn.Layer, 1})
    wantedLayer = get(Ahorn.persistence, "placements_layer", "entities")

    global drawingLayers = layers
    global toolsLayer = Ahorn.getLayerByName(layers, "tools")
    global targetLayer = Ahorn.selectLayer!(layers, wantedLayer, "entities")
end

function applyTileSelecitonBrush!(target::Ahorn.TileSelection, clear::Bool=false)
    roomTiles = target.fg? relevantRoom.fgTiles : relevantRoom.bgTiles
    tiles = clear? fill('0', size(target.tiles)) : target.tiles

    x, y = floor(Int, target.selection.x / 8), floor(Int, target.selection.y / 8)
    brush = Ahorn.Brush(
        "Selection Finisher",
        clear? fill(1, size(tiles) .- 2) : tiles[2:end - 1, 2:end - 1] .!= '0'
    )

    Ahorn.applyBrush!(brush, roomTiles, tiles[2:end - 1, 2:end - 1], x + 1, y + 1)
end

function afterUndo(map::Ahorn.Maple.Map)
    global selections = Ahorn.fixSelections(relevantRoom, selections)
    Ahorn.redrawLayer!(toolsLayer)
end

function afterRedo(map::Ahorn.Maple.Map)
    global selections = Ahorn.fixSelections(relevantRoom, selections)
    Ahorn.redrawLayer!(toolsLayer)
end

function finalizeSelections!(targets::Set{Tuple{String, Ahorn.Rectangle, Any, Number}})
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

function initSelections!(targets::Set{Tuple{String, Ahorn.Rectangle, Any, Number}})
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

function setSelections(map::Ahorn.Maple.Map, room::Ahorn.Maple.Room, newSelections::Set{Tuple{String, Ahorn.Rectangle, Any, Number}})
    if room.name == relevantRoom.name
        empty!(selections)
        union!(selections, Ahorn.fixSelections(relevantRoom, newSelections))

        Ahorn.redrawLayer!(toolsLayer)
    end
end

function getSelections()
    return true, selections
end

function applyMovement!(target::Union{Ahorn.Maple.Entity, Ahorn.Maple.Trigger}, ox::Number, oy::Number, node::Number=0)
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

function applyMovement!(decal::Ahorn.Maple.Decal, ox::Number, oy::Number, node::Number=0)
    decal.x += ox
    decal.y += oy
end

function applyMovement!(target::Ahorn.TileSelection, ox::Number, oy::Number, node::Number=0)
    target.offsetX += ox
    target.offsetY += oy

    target.selection = Ahorn.Rectangle(target.startX + floor(target.offsetX / 8) * 8, target.startY + floor(target.offsetY / 8) * 8, target.selection.w, target.selection.h)
end

function notifyMovement!(entity::Ahorn.Maple.Entity)
    Ahorn.eventToModules(Ahorn.loadedEntities, "moved", entity)
    Ahorn.eventToModules(Ahorn.loadedEntities, "moved", entity, relevantRoom)
end

function notifyMovement!(trigger::Ahorn.Maple.Trigger)
    Ahorn.eventToModules(Ahorn.loadedTriggers, "moved", trigger)
    Ahorn.eventToModules(Ahorn.loadedTriggers, "moved", trigger, relevantRoom)
end

function notifyMovement!(decal::Ahorn.Maple.Decal)
    # Decals doesn't care
end

function notifyMovement!(target::Ahorn.TileSelection)
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

function handleMovement(event::Ahorn.eventKey)
    redraw = false
    step = Ahorn.modifierControl()? 1 : 8

    for selection in selections
        name, box, target, node = selection
        ox, oy = Ahorn.moveDirections[event.keyval] .* step

        if applicable(applyMovement!, target, ox, oy, node)
            applyMovement!(target, ox, oy, node)
            notifyMovement!(target)

            redraw = true
        end
    end

    return redraw
end

function handleResize(event::Ahorn.eventKey)
    redraw = false
    step = Ahorn.modifierControl()? 1 : 8

    for selection in selections
        name, box, target, node = selection
        extraW, extraH = resizeModifiers[event.keyval] .* step

        if (name == "entities" || name == "triggers") && node == 0
            horizontal, vertical = Ahorn.canResize(target)
            minWidth, minHeight = Ahorn.minimumSize(target)

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

function handleScaling(event::Ahorn.eventKey)
    redraw = false
    for selection in selections
        name, box, target, node = selection
        msx, msy = scaleMultipliers[event.keyval]

        if isa(target, Ahorn.Maple.Decal)
            target.scaleX *= msx
            target.scaleY *= msy

            redraw = true
        end
    end

    return redraw
end

function handleAddNodes(event::Ahorn.eventKey)
    redraw = false

    for selection in selections
        name, box, target, node = selection

        if name == "entities" || name == "triggers"
            least, most = Ahorn.nodeLimits(target)
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

function handleDeletion(selections::Set{Tuple{String, Ahorn.Rectangle, Any, Number}})
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
        targetList = Ahorn.selectionTargets[name](relevantRoom)

        index = findfirst(targetList, target)
        if index != 0 
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
        end
    end

    # Deletion for decals
    for selection in decalSelections    
        name, box, target, node = selection
        targetList = Ahorn.selectionTargets[name](relevantRoom)

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
function keyboard(event::Ahorn.eventKey)
    needsRedraw = false
    layersSelected = getLayersSelected(selections)
    snapshot = Ahorn.History.MultiSnapshot("Selections", Ahorn.History.Snapshot[
        Ahorn.History.RoomSnapshot("Selections", Ahorn.loadedState.room),
        Ahorn.History.SelectionSnapshot("Selections", relevantRoom, selections)
    ])

    for hotkey in hotkeys
        if Ahorn.active(hotkey, event)
            needsRedraw |= Ahorn.callback(hotkey)
        end
    end

    if haskey(Ahorn.moveDirections, event.keyval)
        needsRedraw |= handleMovement(event)
    end

    if haskey(resizeModifiers, event.keyval)
        needsRedraw |= handleResize(event)
    end

    if haskey(scaleMultipliers, event.keyval) && !Ahorn.modifierControl()
        needsRedraw |= handleScaling(event)
    end

    if event.keyval == addNodeKey && !Ahorn.modifierControl()
        needsRedraw |= handleAddNodes(event)
    end

    if event.keyval == Ahorn.Gtk.GdkKeySyms.Delete && !Ahorn.modifierControl()
        needsRedraw |= handleDeletion(selections)
    end

    if needsRedraw
        Ahorn.History.addSnapshot!(snapshot)
        Ahorn.redrawLayer!(toolsLayer)
        redrawTargetLayer!(targetLayer, layersSelected)
    end

    return true
end

end