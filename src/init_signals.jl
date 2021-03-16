function initSignals(window::Gtk.GtkWindow, canvas::Gtk.GtkCanvas)
    @guarded draw(canvas) do widget
        if loadedState.map !== nothing && isa(loadedState.map, Map)
            startTime = time()

            lastDrawDeltaTime = startTime - lastCanvasDraw
            global lastCanvasDraw = time()

            debug.log("Canvas was last drawn: $lastDrawDeltaTime seconds ago", "DRAWING_CANVAS_DRAW_DURATION")

            drawMap(canvas, camera, loadedState.map)

            stopTime = time()
            deltaTime = stopTime - startTime
            debug.log("Drawing canvas took $deltaTime seconds, approx $(1 / deltaTime) fps", "DRAWING_CANVAS_DRAW_DURATION")

            persistence["camera_position_x"] = camera.x
            persistence["camera_position_y"] = camera.y
            persistence["camera_scale"] = camera.scale
        end
    end

    add_events(canvas,
        GConstants.GdkEventMask.SCROLL |
        GConstants.GdkEventMask.BUTTON_PRESS |
        GConstants.GdkEventType.DOUBLE_BUTTON_PRESS |
        GConstants.GdkEventMask.BUTTON_RELEASE |
        GConstants.GdkEventMask.BUTTON1_MOTION |
        GConstants.GdkEventMask.BUTTON3_MOTION |
        GConstants.GdkEventMask.LEAVE_NOTIFY
    )

    signal_connect(ExitWindow.exitAhorn, window, "delete_event")
    signal_connect(
        function(window::GtkWindow, event::Gtk.GdkEventAny)
            persistence["start_maximized"] = get_gtk_property(window, :is_maximized, Bool)

            return false
        end,
        window,
        "window-state-event"
    )

    # signal_connect(resize_event, window, "resize")
    signal_connect(key_press_event, window, "key-press-event")
    signal_connect(key_release_event, window, "key-release-event")

    signal_connect(focus_out_event, window, "focus-out-event")

    signal_connect(scroll_event, canvas, "scroll-event")
    signal_connect(motion_notify_event, canvas, "motion-notify-event")
    signal_connect(button_press_event, canvas, "button-press-event")
    signal_connect(button_release_event, canvas, "button-release-event")
    signal_connect(leave_notify_event, canvas, "leave-notify-event")
end