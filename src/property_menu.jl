lockedEntityEditingFields = ["x", "y", "width", "height"]
lastPropertyWindow = nothing
lastPropertyWindowDestroyed = false

function spawnPropertyWindow(title::String, options::Array{ConfigWindow.Option, 1}, callback::Function, lockedPositions::Array{String, 1})
    destroyPrevious = get(config, "properties_destroy_previous_window", true)
    keepPreviousPosition = get(config, "properties_keep_previous_position", true)
    alwaysOnTop = get(config, "properties_always_on_top", true)

    winX, winY = 0, 0
    winScreen = nothing

    propertyWindow = ConfigWindow.createWindow(title, options, callback, lockedPositions=lockedPositions)
    signal_connect(propertyWindow, :destroy) do widget
        global lastPropertyWindowDestroyed = true
    end

    visible(propertyWindow, false)

    if keepPreviousPosition && isa(lastPropertyWindow, Gtk.GtkWindowLeaf) && !lastPropertyWindowDestroyed
        winX, winY = GAccessor.position(lastPropertyWindow)
        winScreen = GAccessor.screen(lastPropertyWindow)

        GAccessor.position(propertyWindow, winX, winY)
        GAccessor.screen(propertyWindow, winScreen)
    end

    GAccessor.transient_for(propertyWindow, window)
    GAccessor.keep_above(propertyWindow, alwaysOnTop)

    showall(propertyWindow)
    visible(propertyWindow, true)

    if destroyPrevious && isa(lastPropertyWindow, Gtk.GtkWindowLeaf)
        Gtk.destroy(lastPropertyWindow)
    end

    global lastPropertyWindow = propertyWindow
    global lastPropertyWindowDestroyed = false
end

function displayProperties(x::Number, y::Number, room::Maple.Room, targetLayer::Layer, toolsLayer::Layer, selections::Set{Tuple{String, Rectangle, Any, Number}}=Set{Tuple{String, Rectangle, Any, Number}}())
    targets = Any[]
    rect = Rectangle(x, y, 1, 1)

    if isempty(selections)
        selection = bestSelection(getSelected(room, targetLayer, rect))
        if selection !== nothing
            layer, box, target, node = selection
            push!(targets, target)
        end
    
    else
        success, base = hasSelectionAt(selections, rect)
        
        if success && (isa(base, Entity) || isa(base, Trigger))
            push!(targets, base)

            for selection in selections
                layer, box, target, node = selection

                if isa(target, Entity) || isa(target, Trigger)
                    if base.name == target.name && base.id != target.id
                        push!(targets, target)
                    end
                end
            end
        end
    end

    if !isempty(targets)
        if isa(target, Entity) || isa(target, Trigger)
            function callback(data::Dict{String, Any})
                updateTarget = true

                minWidth, minHeight = minimumSize(target)
                hasWidth, hasHeight = haskey(target.data, "width"), haskey(target.data, "height")
                width, height = Int(get(data, "width", minWidth)), Int(get(data, "width", minHeight))

                if hasWidth && width < minWidth || hasHeight && height < minHeight
                    updateTarget = ask_dialog("The size specified is smaller than the recommended minimum size ($minWidth, $minHeight)\nDo you want to keep this size regardless?", window)
                end

                if updateTarget
                    History.addSnapshot!(History.RoomSnapshot("Properties", room))

                    for target in targets
                        merge!(target.data, deepcopy(data))
                    end

                    redrawLayer!(targetLayer)
                    redrawLayer!(toolsLayer)
                end
            end

            baseTarget = targets[1]
            ids = join([Int(t.id) for t in targets], ", ")
            ignores = length(targets) > 1? String["x", "y", "nodes"] : String[]
            options = entityConfigOptions(baseTarget, ignores)

            if !isempty(options)
                spawnPropertyWindow("$(baseTitle) - Editing '$(baseTarget.name)' - $ids", options, callback, lockedEntityEditingFields)
            end
        end
    end
end