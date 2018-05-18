# Todo
# Depricate "box" in selections?
# Keep only target instead?
# See how that goes once tiles are supported in here
# We have to make a new rectangle either way, might was well just do the cheap calculations for sanity reasons

module Selection

displayName = "Selection"

drawingLayers = Main.Layer[]

toolsLayer = nothing
targetLayer = nothing

# Drag selection, track individually for easy replacement
selectionRect = Main.Rectangle(0, 0, 0, 0)
selections = Set{Tuple{String, Main.Rectangle, Any, Number}}[]

lastX, lastY = -1, -1
shouldDrag = true

function drawSelections(layer::Main.Layer, room::Main.Room)
    drawnTargets = Set()
    ctx = Main.creategc(toolsLayer.surface)

    if selectionRect !== nothing && selectionRect.w > 0 && selectionRect.h > 0 && !shouldDrag
        Main.drawRectangle(ctx, selectionRect, Main.colors.selection_selection_fc, Main.colors.selection_selection_bc)
    end

    for selection in selections
        layer, box, target, node = selection

        if layer == "entities" && !(target in drawnTargets)
            Main.renderEntitySelection(ctx, toolsLayer, target, Main.loadedRoom)
        end

        push!(drawnTargets, target)

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
    empty!(selections)
    global selectionRect = nothing

    Main.redrawLayer!(toolsLayer)
end

function toolSelected(subTools::Main.ListContainer, layers::Main.ListContainer, materials::Main.ListContainer)
    Main.updateTreeView!(subTools, [])
    Main.updateTreeView!(layers, ["entities", "fgDecals", "bgDecals"], row -> row[1] == Main.layerName(targetLayer))

    Main.redrawingFuncs["tools"] = drawSelections
    Main.redrawLayer!(toolsLayer)
end

function layerSelected(list::Main.ListContainer, materials::Main.ListContainer, selected::String)
    global selections = Set{Tuple{String, Main.Rectangle, Any, Number}}()
    global targetLayer = Main.getLayerByName(Main.drawingLayers, selected)
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

        success, target = Main.hasSelectionAt(selections, Main.Rectangle(x1, y1, 1, 1))
        global shouldDrag = success
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
                end
            end

            Main.redrawLayer!(toolsLayer)
            Main.redrawLayer!(targetLayer)
        end
    end
end

function selectionFinishAbs(rect::Main.Rectangle)
    # If we are draging we are techically not making a new selection
    if !shouldDrag
        Main.updateSelections!(selections, Main.loadedRoom, Main.layerName(targetLayer), rect, retain=Main.modifierShift())
    end

    clearDragging!()

    global selectionRect = Main.Rectangle(0, 0, 0, 0)

    Main.redrawLayer!(toolsLayer)
end

function leftClickAbs(x::Number, y::Number)
    Main.updateSelections!(selections, Main.loadedRoom, Main.layerName(targetLayer), Main.Rectangle(x, y, 1, 1), retain=Main.modifierShift())
    clearDragging!()
    
    Main.redrawLayer!(toolsLayer)
end

function layersChanged(layers::Array{Main.Layer, 1})
    global drawingLayers = layers
    global toolsLayer = Main.getLayerByName(layers, "tools")
    global targetLayer = Main.updateLayerList!(layers, targetLayer, "fgTiles")
end

function applyMovement!(entity::Main.Maple.Entity, ox::Number, oy::Number, node::Number=0)
    if node == 0
        entity.data["x"] += ox
        entity.data["y"] += oy

    else
        nodes = get(entity.data, "nodes", ())

        if length(nodes) >= node
            nodes[node] = nodes[node] .+ (ox, oy)
        end
    end
end

function applyMovement!(decal::Main.Maple.Decal, ox::Number, oy::Number, node::Number=0)
    decal.x += ox
    decal.y += oy
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

moveDirections = Dict{Integer, Tuple{Number, Number}}(
    Main.Gtk.GdkKeySyms.Left => (-1, 0),
    Main.Gtk.GdkKeySyms.Right => (1, 0),
    Main.Gtk.GdkKeySyms.Down => (0, 1),
    Main.Gtk.GdkKeySyms.Up => (0, -1)
)

# Turns out having scales besides -1 and 1 on decals causes weird behaviour?
scaleMultipliers = Dict{Integer, Tuple{Number, Number}}(
    # Vertical Mirror
    Int('v') => (-1, 1),

    # Horizontal Mirror
    Int('h') => (1, -1),
)

function handleMovement(event::Main.eventKey)
    redraw = false
    step = Main.modifierControl()? 1 : 8

    for selection in selections
        name, box, target, node = selection
        ox, oy = moveDirections[event.keyval] .* step

        if applicable(applyMovement!, target, ox, oy, node)
            applyMovement!(target, ox, oy, node)

            redraw = true
        end
    end

    return redraw
end

# TODO
# Ask the entity if it can resize in the given direction
# Test this when spikes are selectable
function handleResize(event::Main.eventKey)
    redraw = false
    step = Main.modifierControl()? 1 : 8

    for selection in selections
        name, box, target, node = selection
        extraW, extraH = resizeModifiers[event.keyval] .* step
        horizontal, vertical = Main.canResize(target)

        if name == "entities" && node == 0
            minWidth, minHeight = Main.minimumSize(target)

            baseWidth = get(target.data, "width", minWidth)
            baseHeight = get(target.data, "height", minHeight)

            width = horizontal? (max(baseWidth + extraW, minWidth)) : baseWidth
            height = vertical? (max(baseHeight + extraH, minHeight)) : baseHeight

            target.data["width"] = width
            target.data["height"] = height

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
    targetList = Main.selectionTargets[Main.layerName(targetLayer)](Main.loadedRoom)
    res = !isempty(selections)

    # Sort entities, otherwise deletion will break
    processedSelections = Main.layerName(targetLayer) == "entities"? sort(collect(selections), by=r -> (r[3].id, r[4]), rev=true) : selections
    for selection in processedSelections
        name, box, target, node = selection

        index = findfirst(targetList, target)
        if index != 0
            if node == 0
                deleteat!(targetList, index)

            elseif name == "entities"
                least, most = Main.nodeLimits(target)
                nodes = get(target.data, "nodes", [])

                if length(nodes) - 1 >= least && length(nodes) >= node
                    deleteat!(nodes, node)
                end
            end
        end
    end

    empty!(selections)

    return res
end

# Refactor and prettify code once we know how to handle tiles here,
# this also includes the handle functions
function keyboard(event::Main.eventKey)
    needsRedraw = false

    if haskey(moveDirections, event.keyval)
        needsRedraw |= handleMovement(event)
    end

    if haskey(resizeModifiers, event.keyval)
        needsRedraw |= handleResize(event)
    end

    if haskey(scaleMultipliers, event.keyval)
        needsRedraw |= handleScaling(event)
    end

    if event.keyval == addNodeKey
        needsRedraw |= handleAddNodes(event)
    end

    if event.keyval == Main.Gtk.GdkKeySyms.Delete
        needsRedraw |= handleDeletion(selections)
    end

    if needsRedraw
        Main.redrawLayer!(toolsLayer)
        Main.redrawLayer!(targetLayer)
    end

    return true
end

end