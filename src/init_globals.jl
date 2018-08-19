function initSprites()
    global sprites = loadSprites(joinpath(storageDirectory, "Gameplay.meta"), joinpath(storageDirectory, "Gameplay.png"))
end

function initTilerMetas()
    global fgTilerMeta = TilerMeta(joinpath(storageDirectory, "ForegroundTiles.xml"))
    global bgTilerMeta = TilerMeta(joinpath(storageDirectory, "BackgroundTiles.xml"))
end

function initCamera()
    global camera = Camera(
        get(persistence, "camera_position_x", 0),
        get(persistence, "camera_position_y", 0),
        get(persistence, "camera_scale", get(config, "camera_default_zoom", 4))
    )
end

function initLoadedState()
    global loadedState = LoadedState(
        get(persistence, "files_lastroom", ""),
        get(persistence, "files_lastfile", "")
    )
end

function initConfigs()
    global storageDirectory = joinpath(homedir(), ".ahorn")
    global configFilename = joinpath(storageDirectory, "config.json")
    global persistenceFilename = joinpath(storageDirectory, "persistence.json")

    global config = loadConfig(configFilename, 0)
    global persistence = loadConfig(persistenceFilename, 90)

    debugConfigFilename = joinpath(storageDirectory, "debug.json")
    debug.setConfig(debugConfigFilename, 0)
end