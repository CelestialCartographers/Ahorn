const mousePressed = Dict{Int, Tuple{Gtk.GdkEventButton, Bool, Union{Camera, Bool}}}()
const keyPressed = Dict{Int, Tuple{Gtk.GdkEventKey, Bool}}()

mouseMotion = false
lastSelection = false

cursor = nothing

const dragButton = 3
const clickThreshold = 4

const mouseHandlers = Dict{Int, String}(
    1 => "leftClick",
    2 => "middleClick",
    3 => "rightClick",
    4 => "backClick",
    5 => "forwardClick"
)

const mouseTypePrefix = Dict{Int, String}(
    4 => "",
    5 => "double",
    6 => "tripple"
)

const moveDirections = Dict{Int, Tuple{Number, Number}}(
    Gtk.GdkKeySyms.Left => (-1, 0),
    Gtk.GdkKeySyms.Right => (1, 0),
    Gtk.GdkKeySyms.Down => (0, 1),
    Gtk.GdkKeySyms.Up => (0, -1)
)

mouseButtonHeld(n) = get(mousePressed, n, (false, false, false))[2]
keyHeld(n) = get(keyPressed, n, (false, false))[2]

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
    return loadedState.map !== nothing && loadedState.room !== nothing
end

function shouldConsumeKeys()
    try
        focused = GAccessor.focus(window)
        return !isa(focused, Gtk.GtkEntryLeaf), focused

    catch
        return true
    end
end

function updateCursor(event::eventMouse, camera::Camera, room::Union{Maple.Room, Nothing})
    if room !== nothing
        global cursor = Cursor(event, camera, room)
    end
end

function scroll_event(widget::Gtk.GtkCanvas, event::Gtk.GdkEventScroll)
    changed = event.direction == 0 ? zoomIn!(camera, event) : zoomOut!(camera, event)
    
    if changed
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
        lmbEvent, lmbActive, lmbCamera = get(mousePressed, 1, (false, false, false))
        if lmbActive && mouseMotion != false
            # Don't consider this a seleciton unless its above the treshold
            if !isClick(event, lmbEvent)
                handleSelectionMotion(lmbEvent, lmbCamera, event)
            end
        end

        handleMotion(event, camera)
    end

    global mouseMotion = event
    updateCursor(event, camera, loadedState.room)

    return true
end

function button_press_event(widget::Gtk.GtkCanvas, event::Gtk.GdkEventButton)
    unfocusFilterEntry!()

    mousePressed[event.button] = (event, true, deepcopy(camera))

	return true
end

function button_release_event(widget::Gtk.GtkCanvas, event::Gtk.GdkEventButton)
    buttonEvent, buttonActive, buttonCamera = get(mousePressed, event.button, (false, false, false))

    if shouldHandle() 
        if !isa(buttonEvent, Bool) && isClick(event, buttonEvent)
            handleClicks(event, camera, buttonEvent)

        elseif buttonActive && event.button == 1
            handleSelectionFinish(buttonEvent, buttonCamera, event, camera)
        end
    end
    
    mousePressed[event.button] = (event, false, deepcopy(camera))

	return true
end

# Manually release all active drags
# We can't pass the event to button_release_event as that has a few side effects
function leave_notify_event(canvas::Gtk.GtkCanvas, event::Gtk.GdkEventCrossing)
    for (button, status) in mousePressed
        buttonEvent, buttonActive, buttonCamera = status

        if buttonActive
            if shouldHandle()
                # As we can't trigger clicks from here, treat all instances as draging
                if buttonEvent.button == 1
                    handleSelectionFinish(buttonEvent, buttonCamera, event, camera)
                end

                mousePressed[buttonEvent.button] = (buttonEvent, false, deepcopy(camera))
            end
        end
    end
end

function handleHotkeys(hotkeys::Array{Hotkey, 1}, event::Gtk.GdkEventKey)
    return callbackFirstActive(hotkeys, event)
end

function key_press_event(widget::Gtk.GtkWindowLeaf, event::Gtk.GdkEventKey)
    keyPressed[event.keyval] = (event, true)
    consume, textEntry = shouldConsumeKeys()

    # Always handle non specific hotkeys
    handleHotkeys(hotkeys, event)

    if consume
        handleKeyPressed(event)
    
    else
        # Let tools manager handle hotkeys, but not pass it onto the tools
        handleKeyPressed(event, false)

        return handleFilterKeyPressed(textEntry, event)
    end

    return consume
end

function key_release_event(widget::Gtk.GtkWindowLeaf, event::Gtk.GdkEventKey)
    keyPressed[event.keyval] = (event, false)
    consume = shouldConsumeKeys()
    if consume
        handleKeyReleased(event)
    end

    return consume
end