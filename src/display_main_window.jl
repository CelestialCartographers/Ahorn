function displayMainWindow()
    # Fixes theme issues on Windows
    if is_windows()
        ENV["GTK_THEME"] = get(ENV, "GTK_THEME", "win32")
        ENV["GTK_CSD"] = get(ENV, "GTK_CSD", "0")
    end

    initConfigs()
    
    configured = configureCelesteDir()
    if !configured
        error("Celeste installation not configured")
    end

    extractGamedata(storageDirectory, get(debug.config, "ALWAYS_FORCE_GAME_EXTRACTION", false))

    initSprites()
    initTilerMetas()
    initCamera()
    initLoadedState()

    updateToolDisplayNames!(loadedTools)
    updateToolList!(toolList)

    initExternalModules()

    # Update the room list so it has rooms
    updateTreeView!(roomList, getTreeData(loadedState.map))

    selectLoadedRoom!(roomList)

    windowTitle = baseTitle
    if loadedState.map !== nothing
        windowTitle = "$baseTitle - $(Maple.getSideName(loadedState.side))"
    end

    hidden = get(debug.config, "DEBUG_MENU_DROPDOWN", false)? String[] : String["Debug"]
    global menubar = Menubar.generateMenubar(menubarHeaders, menubarItems, hidden)

    global box = Box(:v)
    global grid = generateMainGrid()
    
    # Everything else should be ready, safe to make the window
    global window = Window(windowTitle, 1280, 720, true, true, icon=windowIcon, gravity=GdkGravity.GDK_GRAVITY_CENTER)
    push!(box, grid)
    push!(window, box)

    initSignals(window, canvas)

    # If the window was previously maximized, maximize again
    if get(persistence, "start_maximized", false)
        maximize(window)
    end

    # Fixes Grids rendering right to left on certain locales
    GAccessor.direction(window, 1)

    showall(window)
    interactiveWorkaround(window)
end