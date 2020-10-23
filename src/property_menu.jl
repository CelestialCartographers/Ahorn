const entityTriggerUnion = Union{Maple.Entity, Maple.Trigger}

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

function getTargets(x::Number, y::Number, room::Maple.Room, targetLayer::Layer, selections::Set{Ahorn.SelectedObject}=Set{Ahorn.SelectedObject}())
    targets = Any[]
    rect = Rectangle(x, y, 1, 1)

    if isempty(selections)
        selection = bestSelection(getSelected(room, targetLayer, rect))

        if selection !== nothing
            push!(targets, selection.target)
        end

    else
        base = hasSelectionAt(selections, rect, room)

        if isa(base, Entity) || isa(base, Trigger)
            push!(targets, base)

            for selection in selections
                target = selection.target
                if isa(target, Entity) || isa(target, Trigger)
                    if base.name == target.name && base.id != target.id
                        push!(targets, target)
                    end
                end
            end

        elseif isa(base, Decal)
            push!(targets, base)
            append!(targets, [
                selection.target for selection in selections if isa(selection.target, Decal) && selection.target != base
            ])
        end
    end

    return targets
end

function displayProperties(x::Number, y::Number, room::Maple.Room, targetLayer::Layer, toolsLayer::Layer, baseTarget::entityTriggerUnion, targets::Array{Any, 1})
    callback = function(data::Dict{String, Any})
        updateTarget = true

        minWidth, minHeight = minimumSize(baseTarget)
        hasWidth, hasHeight = haskey(baseTarget.data, "width"), haskey(baseTarget.data, "height")
        width, height = Int(get(data, "width", minWidth)), Int(get(data, "height", minHeight))

        if hasWidth && width < minWidth || hasHeight && height < minHeight
            updateTarget = Ahorn.topMostAskDialog("The size specified is smaller than the recommended minimum size ($minWidth, $minHeight)\nDo you want to keep this size regardless?", lastPropertyWindow)
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
    ignores = editingIgnored(baseTarget, length(targets) > 1)
    options = propertyOptions(baseTarget, ignores)
    fieldOrder = editingOrder(baseTarget)

    if !isempty(options)
        spawnPropertyWindow("$(baseTitle) - Editing '$(baseTarget.name)' - ID: $ids", options, callback, fieldOrder)
    end
end

function displayProperties(x::Number, y::Number, room::Maple.Room, targetLayer::Layer, toolsLayer::Layer, baseTarget::Maple.Decal, targets::Array{Any, 1})
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

    ignores = editingIgnored(baseTarget, length(targets) > 1)
    options = propertyOptions(baseTarget, ignores)
    fieldOrder = editingOrder(baseTarget)

    if !isempty(options)
        spawnPropertyWindow("$(baseTitle) - Editing '$(splitext(baseTarget.texture)[1])'", options, callback, fieldOrder)
    end
end


function displayProperties(x::Number, y::Number, room::Maple.Room, targetLayer::Layer, toolsLayer::Layer, baseTarget::Nothing, targets::Array{Any, 1})
    # Do nothing
end

function displayProperties(x::Number, y::Number, room::Maple.Room, targetLayer::Layer, toolsLayer::Layer, selections::Set{Ahorn.SelectedObject}=Set{Ahorn.SelectedObject}())
    targets = getTargets(x, y, room, targetLayer, selections)
    baseTarget = get(targets, 1, nothing)

    displayProperties(x, y, room, targetLayer, toolsLayer, baseTarget, targets)
end