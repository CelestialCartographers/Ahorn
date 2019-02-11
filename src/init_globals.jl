function initSprites()
    atlases["Gameplay"] = loadSprites(joinpath(storageDirectory, "Sprites", "Gameplay.meta"), joinpath(storageDirectory, "Sprites", "Gameplay.png"))
end

function initTilerMetas()
    loadXMLMeta()
end

function initCamera()
    global camera = Camera(
        get(persistence, "camera_position_x", 0),
        get(persistence, "camera_position_y", 0),
        get(persistence, "camera_scale", get(config, "camera_default_zoom", 4))
    )

    updateCameraZoomVariables()
end

function initLoadedState()
    global loadedState = LoadedState(
        get(persistence, "files_lastroom", ""),
        get(persistence, "files_lastfile", "")
    )
end

function initLangdata()
    loadLangfile()
end

function initConfigs()
    if Sys.iswindows()
        global storageDirectory = joinpath(ENV["LOCALAPPDATA"], "Ahorn")
        
    else
        global storageDirectory = joinpath(get(ENV, "XDG_CONFIG_HOME", joinpath(get(ENV, "HOME", ""), ".config")) , "Ahorn")
    end

    global configFilename = joinpath(storageDirectory, "config.json")
    global persistenceFilename = joinpath(storageDirectory, "persistence.json")

    global config = loadConfig(configFilename, 0)
    global persistence = loadConfig(persistenceFilename, 90)

    debugConfigFilename = joinpath(storageDirectory, "debug.json")
    debug.setConfig(debugConfigFilename, 0)
end

function initMenubar()
    debugEnabled = get(debug.config, "DEBUG_MENU_DROPDOWN", false)
    choices = menubarChoices

    if debugEnabled
        append!(choices, menubarDebugChoices)
    end

    append!(choices, menubarEndChoices)

    global menubar = Menubar.generateMenubar(choices)
end