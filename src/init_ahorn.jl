include("extract_sprites_images.jl")

@static if is_windows()
    using WinReg
end

function findSteamInstallDir()
    if is_windows()
        try
            # 64bit 
            return querykey(WinReg.HKEY_LOCAL_MACHINE, "SOFTWARE\\WOW6432Node\\Valve\\Steam", "InstallPath")

        catch e
            # 32bit
            return querykey(WinReg.HKEY_LOCAL_MACHINE, "SOFTWARE\\Valve\\Steam", "InstallPath")
        end

    elseif is_apple()
        return joinpath(homedir(), "Library/Application Support/Steam")

    elseif is_linux()
        return joinpath(homedir(), ".local/share/Steam")
    end
end

function findCelesteDir()
    steam = findSteamInstallDir()
    steamfn = joinpath(steam, "steamapps", "common", "Celeste", "Celeste.exe")

    if isfile(steamfn)
        return true, steamfn
    end

    return false, ""
end

function configureCelesteDir()
    if !haskey(config, "celeste_dir")
        found, filename = findCelesteDir()

        if !found
            info_dialog("Ahorn depends on the Celeste installation directory to function.\nPlease use the file dialog to select 'Celeste.exe' on your computer.", window)
            filename = open_dialog("Select Celeste.exe", window, tuple("*.exe"))

            if filename === nothing
                return false

            elseif lowercase(basename(filename)) != "celeste.exe"
                warn_dialog("The file you selected is not named 'celeste.exe'\nWill attempt to use this as the install directory anyway.", window)
            end
        end

        celeste_dir = dirname(filename)

        celesteGraphics = joinpath(celeste_dir, "Content", "Graphics") 
        celesteAtlases = joinpath(celesteGraphics, "Atlases")
    
        if !isdir(celesteGraphics) || !isdir(celesteAtlases)
            warn_dialog("The directory you selected does not contain the required paths.\nThe subdirectories Content/Graphics/ and Atlases/ of a celeste installation with their contents are required for Ahorn to function.", window)
            exit()
        end

        config["celeste_dir"] = celeste_dir
        info_dialog("Ahorn will now extract all files needed.\nPlease close this window to continue.", window)
    end

    return true
end

function extractGamedata(storage::String, force::Bool=false)
    celesteGraphics = joinpath(config["celeste_dir"], "Content", "Graphics") 
    celesteAtlases = joinpath(celesteGraphics, "Atlases")

    gameplaySprites = joinpath(storage, "Gameplay.png")
    gameplayMeta = joinpath(storage, "Gameplay.meta")
    foregroundTilesXML = joinpath(storage, "ForegroundTiles.xml")
    backgroundTilesXML = joinpath(storage, "BackgroundTiles.xml")

    if !isfile(gameplaySprites) || force
        dumpSprites(celesteAtlases, storage)
    end

    if !isfile(gameplayMeta) || force
        cp(joinpath(celesteAtlases, "Gameplay.meta"), gameplayMeta)
    end

    if !isfile(foregroundTilesXML) || force
        cp(joinpath(celesteGraphics, "ForegroundTiles.xml"), foregroundTilesXML)
    end

    if !isfile(backgroundTilesXML) || force
        cp(joinpath(celesteGraphics, "BackgroundTiles.xml"), backgroundTilesXML)
    end
end