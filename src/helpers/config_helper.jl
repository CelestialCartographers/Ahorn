function attemptLoadConfig(fn::String, bufferTime::Number=0, default::Dict{K, V}=Dict{Any, Any}()) where {K, V}
    try
        return loadConfig(fn, bufferTime, default)

    catch
        # Doesn't really matter what it is failing here, we would still want the default config

        failedFn = fn * ".failed"
        warningMessage = """Failed to parse config at "$fn".
            Program will exit if defaults are not used.
            Use defaults and continue?"""
        
        if ask_dialog(warningMessage)
            mv(fn, failedFn, force=true)

            config = Config(fn, bufferTime, default)
            saveConfig(config)

            return config

        else
            exit()
        end
    end
end