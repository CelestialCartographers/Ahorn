lockedEntityEditingFields = ["x", "y", "width", "height"]
lockedDecalEditingFields = ["x", "y", "scaleX", "scaleY", "texture"]
lastPropertyWindow = nothing
lastPropertyWindowDestroyed = false

function spawnPropertyWindow(title::String, options::Array{Form.Option, 1}, callback::Function, lockedPositions::Array{String, 1}=String[])
    destroyPrevious = get(config, "properties_destroy_previous_window", true)
    keepPreviousPosition = get(config, "properties_keep_previous_position", true)
    alwaysOnTop = get(config, "properties_always_on_top", true)

    winX, winY = 0, 0
    winScreen = nothing

    section = Form.Section("properties", options, fieldOrder=lockedPositions)
    propertyWindow = Form.createFormWindow(title, section, callback=callback)
    @guarded signal_connect(propertyWindow, :destroy) do widget
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

function getTargets(x::Number, y::Number, room::Maple.Room, targetLayer::Layer, selections::Set{Tuple{String, Rectangle, Any, Number}}=Set{Tuple{String, Rectangle, Any, Number}}())
    targets = Any[]
    rect = Rectangle(x, y, 1, 1)

    if isempty(selections)
        selection = bestSelection(getSelected(room, targetLayer, rect))
        if selection !== nothing
            layer, box, target, node = selection
            push!(targets, target)
        end
    
    else    
        base = hasSelectionAt(selections, rect, room)
        
        if isa(base, Entity) || isa(base, Trigger)
            push!(targets, base)

            for (layer, box, target, node) in selections
                if isa(target, Entity) || isa(target, Trigger)
                    if base.name == target.name && base.id != target.id
                        push!(targets, target)
                    end
                end
            end

        elseif isa(base, Decal)
            push!(targets, base)
            push!(targets, [
                target for (layer, box, target, node) in selections if isa(target, Decal) && target != base
            ]...)
        end
    end

    return targets
end

function displayProperties(x::Number, y::Number, room::Maple.Room, targetLayer::Layer, toolsLayer::Layer, selections::Set{Tuple{String, Rectangle, Any, Number}}=Set{Tuple{String, Rectangle, Any, Number}}())
    targets = getTargets(x, y, room, targetLayer, selections)

    if !isempty(targets)
        baseTarget = targets[1]

        if isa(baseTarget, Entity) || isa(baseTarget, Trigger)
            callback = function(data::Dict{String, Any})
                updateTarget = true

                minWidth, minHeight = minimumSize(baseTarget)
                hasWidth, hasHeight = haskey(baseTarget.data, "width"), haskey(baseTarget.data, "height")
                width, height = Int(get(data, "width", minWidth)), Int(get(data, "height", minHeight))

                if hasWidth && width < minWidth || hasHeight && height < minHeight
                    updateTarget = ask_dialog("The size specified is smaller than the recommended minimum size ($minWidth, $minHeight)\nDo you want to keep this size regardless?", lastPropertyWindow)
                end

                if updateTarget
                    History.addSnapshot!(History.RoomSnapshot("Properties", room))

                    for target in targets
                        if isa(target, Entity) || isa(target, Trigger)
                            merge!(target.data, deepcopy(data))
                        end
                    end

                    redrawLayer!(targetLayer)
                    redrawLayer!(toolsLayer)
                end
            end

            ids = join([Int(t.id) for t in targets], ", ")
            ignores = length(targets) > 1 ? String["x", "y", "width", "height", "nodes"] : String[]
            options = entityConfigOptions(baseTarget, ignores)

            if !isempty(options)
                spawnPropertyWindow("$(baseTitle) - Editing '$(baseTarget.name)' - ID: $ids", options, callback, lockedEntityEditingFields)
            end

        elseif isa(baseTarget, Decal)
            callback = function(data::Dict{String, Any})
                History.addSnapshot!(History.RoomSnapshot("Properties", room))

                for target in targets
                    if isa(target, Decal)
                        texture = hasExt(data["texture"], ".png") ? data["texture"] : data["texture"] * ".png"

                        target.x = get(data, "x", target.x)
                        target.y = get(data, "y", target.y)

                        target.texture = texture

                        target.scaleX = data["scaleX"]
                        target.scaleY = data["scaleY"]
                    end
                end

                redrawLayer!(targetLayer)
                redrawLayer!(toolsLayer)
            end

            ignores = length(targets) > 1 ? String["x", "y"] : String[]
            options = decalConfigOptions(baseTarget, ignores)

            if !isempty(options)
                spawnPropertyWindow("$(baseTitle) - Editing '$(splitext(baseTarget.texture)[1])'", options, callback, lockedDecalEditingFields)
            end
        end
    end
end