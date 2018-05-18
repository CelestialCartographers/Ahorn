mousePressed = Dict{Integer, Tuple{Gtk.GdkEventButton, Bool, Union{Camera, Bool}}}()
keyPressed = Dict{Integer, Tuple{Gtk.GdkEventKey, Bool}}()
mouseMotion = false
lastSelection = false

const dragButton = 0x3
const clickThreshold = 4

mouseButtonHeld(n::Integer) = get(mousePressed, n, (false, false, false))[2]
keyHeld(n::Integer) = get(keyPressed, n, (false, false))[2]

# Saner way to get modifier keys in tools
modifierControl() = keyHeld(Gtk.GdkKeySyms.Control_L) || Main.keyHeld(Main.Gtk.GdkKeySyms.Control_R)
modifierShift() = keyHeld(Gtk.GdkKeySyms.Shift_L) || Main.keyHeld(Main.Gtk.GdkKeySyms.Shift_R)
modifierMeta() = keyHeld(Gtk.GdkKeySyms.Meta_L) || Main.keyHeld(Main.Gtk.GdkKeySyms.Meta_R)
modifierAlt() = keyHeld(Gtk.GdkKeySyms.Alt_L) || Main.keyHeld(Main.Gtk.GdkKeySyms.Alt_R)
modifierSuper() = keyHeld(Gtk.GdkKeySyms.Super_L) || Main.keyHeld(Main.Gtk.GdkKeySyms.Super_R)
modifierHyper() = keyHeld(Gtk.GdkKeySyms.Hyper_L) || Main.keyHeld(Main.Gtk.GdkKeySyms.Hyper_R)

# Event -> Map coordinates
getMapCoordinates(camera::Camera, mouseX::Number, mouseY::Number) = (floor(Int, (mouseX + camera.x) / camera.scale / 8) + 1, floor(Int, (mouseY + camera.y) / camera.scale / 8) + 1)
getMapCoordinatesAbs(camera::Camera, mouseX::Number, mouseY::Number) = (floor(Int, (mouseX + camera.x) / camera.scale), floor(Int, (mouseY + camera.y) / camera.scale))

# Map -> Room coordinates
mapToRoomCoordinates(x::Number, y::Number, room::Maple.Room) = (x, y) .- floor.(Int, room.position ./ 8)
mapToRoomCoordinatesAbs(x::Number, y::Number, room::Maple.Room) = (x, y) .- room.position

function isClick(event::eventMouse, prevEvent::eventMouse, threshold::Number=clickThreshold)
    return event.x - threshold <= prevEvent.x <= event.x + threshold && event.y - threshold <= prevEvent.y <= event.y + threshold
end

function shouldHandle()
    return loadedMap !== nothing && loadedRoom !== nothing
end

function scroll_event(widget::Gtk.GtkCanvas, event::Gtk.GdkEventScroll)
    prevScale = camera.scale

    if event.direction == 0
        if minimumZoom <= camera.scale * 2 <= maximumZoom
            global camera.scale = camera.scale * 2
            global camera.x = round(Int, camera.x * 2 + event.x)
            global camera.y = round(Int, camera.y * 2 + event.y)
        end

    else
        if minimumZoom <= camera.scale / 2 <= maximumZoom
            global camera.scale = camera.scale / 2
            global camera.x = round(Int, (camera.x - event.x) / 2)
            global camera.y = round(Int, (camera.y - event.y) / 2)
        end
    end

    if prevScale != camera.scale
        draw(canvas)
    end

	return true
end

function focus_out_event(widget::Gtk.GtkWindowLeaf, event::Gtk.GdkEventAny)
    for (key, data) in keyPressed
        keyPressed[key] = (data[1], false)
    end
end

function motion_notify_event(widget::Gtk.GtkCanvas, event::Gtk.GdkEventMotion)
    # Disable draging outside of the widget
    # Add special case for edgepaning?
    if event.x < 0 || event.x > width(widget) || event.y < 0 || event.y > height(widget)
        # Reset mouse draging status when going off the screen
        for button in keys(mousePressed)
            mousePressed[button] = (mousePressed[button][1], false, camera)
        end

        return true
    end

    if mouseMotion == false
        mouseMotion = event
    end

    dragEvent, dragActive, dragCamera = get(mousePressed, dragButton, (false, false, false))
    if dragActive && mouseMotion != false
        global camera.x = round(Int, camera.x - event.x + mouseMotion.x)
        global camera.y = round(Int, camera.y - event.y + mouseMotion.y)

        draw(canvas)
    end

    if shouldHandle()
        lmbEvent, lmbActive, lmbCamera = get(mousePressed, 0x1, (false, false, false))
        if lmbActive && mouseMotion != false
            # Don't consider this a seleciton unless its above the treshold
            if !isClick(event, lmbEvent)
                handleSelectionMotion(lmbEvent, lmbCamera, event)
            end
        end

        handleMotion(event, camera)
    end

    global mouseMotion = event

    return true
end

function button_press_event(widget::Gtk.GtkCanvas, event::Gtk.GdkEventButton)
    mousePressed[event.button] = (event, true, deepcopy(camera))

	return true
end

function button_release_event(widget::Gtk.GtkCanvas, event::Gtk.GdkEventButton)
    buttonEvent, buttonActive, buttonCamera = get(mousePressed, event.button, (false, false, false))

    if shouldHandle() 
        if isClick(event, buttonEvent)
            handleClicks(event, camera)

        elseif buttonActive && event.button == 0x1
            handleSelectionFinish(buttonEvent, buttonCamera, event)
        end
    end
    
    mousePressed[event.button] = (event, false, deepcopy(camera))

	return true
end

function key_press_event(widget::Gtk.GtkWindowLeaf, event::Gtk.GdkEventKey)
    keyPressed[event.keyval] = (event, true)
    handleKeyPressed(event)

    for hotkey in hotkeys
        if active(hotkey, event)
            callback(hotkey)
        end
    end

    return true
end

function key_release_event(widget::Gtk.GtkWindowLeaf, event::Gtk.GdkEventKey)
    keyPressed[event.keyval] = (event, false)
    handleKeyReleased(event)

    return true
end