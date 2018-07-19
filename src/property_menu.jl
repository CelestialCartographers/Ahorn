lockedEntityEditingFields = ["x", "y", "width", "height"]
lastPropertyWindow = nothing
lastPropertyWindowDestroyed = false

function spawnPropertyWindow(title::String, options::Array{ConfigWindow.Option, 1}, callback::Function, lockedPositions::Array{String, 1})
    destroyPrevious = get(config, "properties_destroy_previous_window", true)
    keepPreviousPosition = get(config, "properties_keep_previous_position", true)
    alwaysOnTop = get(config, "properties_always_on_top", true)

    winX, winY = 0, 0
    winScreen = nothing

    window = ConfigWindow.createWindow(title, options, callback, lockedPositions=lockedPositions)
    signal_connect(window, :destroy) do widget
        global lastPropertyWindowDestroyed = true
    end

    visible(window, false)

    if keepPreviousPosition && isa(lastPropertyWindow, Gtk.GtkWindowLeaf) && !lastPropertyWindowDestroyed
        winX, winY = GAccessor.position(lastPropertyWindow)
        winScreen = GAccessor.screen(lastPropertyWindow)

        GAccessor.position(window, winX, winY)
        GAccessor.screen(window, winScreen)
    end

    GAccessor.transient_for(window, Main.window)
    GAccessor.keep_above(window, alwaysOnTop)

    showall(window)
    visible(window, true)

    if destroyPrevious && isa(lastPropertyWindow, Gtk.GtkWindowLeaf)
        Gtk.destroy(lastPropertyWindow)
    end

    global lastPropertyWindow = window
    global lastPropertyWindowDestroyed = false
end

function displayProperties(x::Number, y::Number, room::Maple.Room, targetLayer::Layer)
    rect = Rectangle(x, y, 1, 1)
    selection = bestSelection(getSelected(room, targetLayer, rect))

    if selection !== nothing
        layer, box, target, node = selection
        if layer == "entities" || layer == "triggers"
            function callback(data::Dict{String, Any})
                updateTarget = true

                minWidth, minHeight = Main.minimumSize(target)
                hasWidth, hasHeight = haskey(target.data, "width"), haskey(target.data, "height")
                width, height = Int(get(data, "width", minWidth)), Int(get(data, "width", minHeight))

                if hasWidth && width < minWidth || hasHeight && height < minHeight
                    updateTarget = ask_dialog("The size specified is smaller than the recommended minimum size ($minWidth, $minHeight)\nDo you want to keep this size regardless?", Main.window)
                end

                if updateTarget
                    History.addSnapshot!(History.RoomSnapshot("Properties", room))
                    target.data = deepcopy(data)

                    redrawLayer!(targetLayer)
                end
            end

            options = entityConfigOptions(target)
            spawnPropertyWindow("$(baseTitle) - Editing $(target.name):$(target.id)", options, callback, lockedEntityEditingFields)
        end
    end
end