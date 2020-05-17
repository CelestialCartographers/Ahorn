function displayMainWindow()
    initConfigs()
    initLoadedState()

    windowTitle = baseTitle
    if loadedState.map !== nothing
        windowTitle = "$baseTitle - $(Maple.getSideName(loadedState.side))"
    end

    # Everything else should be ready, safe to make the window
    global window = Window(windowTitle, 1280, 720, true, true, icon=windowIcon, gravity=GdkGravity.GDK_GRAVITY_CENTER)

    disableLoadingScreen = get(debug.config, "DISABLE_LOADING_SCREEN", false)
    progressDialog = nothing
    
    if !disableLoadingScreen
        progressDialog = getProgressDialog(
            title="Starting Ahorn",
            description="Getting ready...",
            stylesheet="",
            parent=window
        )

        showall(progressDialog)
    end
    
    configured = configureCelesteDir()
    if !configured
        error("Celeste installation not configured")
    end

    @progress extractGamedata(storageDirectory, get(debug.config, "ALWAYS_FORCE_GAME_EXTRACTION", false)) "Extracting game assets..." progressDialog

    @progress initSprites() "Getting sprites ready..." progressDialog
    @progress initTilerMetas() "Getting tiles ready..." progressDialog
    @progress initCamera() "Getting camera ready..." progressDialog
    @progress initLangdata() "Getting language files ready..." progressDialog
    @progress initMenubar() "Getting menubar ready..." progressDialog

    @progress Backup.initBackup(persistence) "Starting backup handler..." progressDialog
    @progress FileWatcher.initFileWatcher(normpath(joinpath(config["celeste_dir"], "Mods"))) "Starting file watcher..." progressDialog

    @progress updateToolDisplayNames!(loadedTools) "Getting tools ready..." progressDialog
    @progress updateToolList!(toolList) "Getting tools ready..." progressDialog

    @progress initExternalModules() "Loading external plugins..." progressDialog
    @progress loadAllExternalSprites!() "Loading external sprites..." progressDialog

    @progress updateTreeView!(roomList, getTreeData(loadedState.map)) "Populating room list..." progressDialog

    roomListVisiblityFunctions[get(persistence, "room_list_column_visibility", "all")]()

    selectLoadedRoom!(roomList)
    selectRow!(toolList, 1)

    global box = Box(:v)
    global grid = generateMainGrid()

    push!(box, grid)
    push!(window, box)

    @progress initSignals(window, canvas) "Hooking up signals..." progressDialog

    # If the window was previously maximized, maximize again
    if get(persistence, "start_maximized", false)
        maximize(window)
    end

    @progress draw(canvas) "Warming up drawing..." progressDialog
    @progress showall(window) "Waiting for main window..." progressDialog

    visible(window, true)

    if progressDialog !== nothing
        Gtk.destroy(progressDialog)
    end
    
    interactiveWorkaround(window)
end