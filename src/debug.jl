module debug

configFilename = joinpath(Main.storageDirectory, "debug.json")
defaultConfig = Dict{String, Bool}(
    "DRAWING_VERBOSE" => false,
    "DRAWING_LAYER_DUMP" => false,
    "DRAWING_ENTITY_MISSING" => false,
    "TOOLS_SELECTED" => false,
    "ALWAYS_FORCE_GAME_EXTRACTION" => false,
    "ENABLE_HOTSWAP_HOTKEYS" => false,
    "IGNORE_MINIMUM_SIZE" => false,
    "IGNORE_CAN_RESIZE" => false
)

config = Main.loadConfig(configFilename, defaultConfig)

function log(s::String, shouldPrint::Bool)
    if shouldPrint
        println(s)
    end
end

function log(s::String, key::String)
    if get(config, key, false)
        println(s)
    end
end

end