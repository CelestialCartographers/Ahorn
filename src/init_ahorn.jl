@static if Sys.iswindows()
    using WinReg
end

function findSteamInstallDir()
    if Sys.iswindows()
        try
            # 64bit 
            return querykey(WinReg.HKEY_LOCAL_MACHINE, "SOFTWARE\\WOW6432Node\\Valve\\Steam", "InstallPath")

        catch e
            try
                # 32bit
                return querykey(WinReg.HKEY_LOCAL_MACHINE, "SOFTWARE\\Valve\\Steam", "InstallPath")

            catch e
                # User doesn't have steam installed
                return nothing
            end
        end

    elseif Sys.isapple()
        return joinpath(homedir(), "Library/Application Support/Steam")

    elseif Sys.islinux()
        return joinpath(homedir(), ".local/share/Steam")
    end
end

function findCelesteDir()
    steam = findSteamInstallDir()

    if steam !== nothing
        celesteDir =
            if Sys.isapple()
                joinpath("Celeste", "Celeste.app", "Contents", "MacOS")
            else
                "Celeste"
            end

        steamfn = joinpath(steam, "steamapps", "common", celestDir, "Celeste.exe")

        if isfile(steamfn)
            return true, steamfn
        end
    end

    return false, ""
end

function configureCelesteDir()
    if !haskey(config, "celeste_dir")
        found, filename = findCelesteDir()
        if !found || ask_dialog("Looks like you installed Celeste using Steam!\nAhorn depends on the Celeste installation directory to function; would you like Ahorn to use the Steam installation, or would you rather select a different installation of the game for it to use?", "Use Steam installation", "Manually select Celeste dir", window)
            info_dialog("Ahorn depends on the Celeste installation directory to function.\nPlease use the file dialog to select 'Celeste.exe' on your computer.", window)
            filename = openDialog("Select Celeste.exe", window, tuple("*.exe"))

            if filename == ""
                return false

            elseif lowercase(basename(filename)) != "celeste.exe"
                warn_dialog("The file you selected is not named 'celeste.exe'\nWill attempt to use this as the install directory anyway.", window)
            end
        end

        celeste_dir = dirname(filename)

        celesteGraphics = joinpath(celeste_dir, "Content", "Graphics") 
        celesteAtlases = joinpath(celesteGraphics, "Atlases")
    
        if !isdir(celesteGraphics) || !isdir(celesteAtlases)
            warn_dialog("The directory you selected does not contain the required paths.\nThe subdirectory Content/Graphics/ of a celeste installation with its contents is required for Ahorn to function.", window)
            exit()
        end

        config["celeste_dir"] = celeste_dir
        saveConfig(config, true) # Manually save because it likely hasn't saved this to file
        info_dialog("Ahorn will now extract all files needed. This might take a while!\nPlease close this window to continue.", window)
    end

    return true
end

function needsExtraction(file::String, force::Bool=false)
    return !isfile(file) || force || filesize(file) == 0
end

function needsExtraction(from::String, to::String, force::Bool=false)
    return needsExtraction(to, force) || mtime(from) > mtime(to)
end

function extractGamedata(storage::String, force::Bool=false)
    celesteGraphics = joinpath(config["celeste_dir"], "Content", "Graphics") 
    celesteAtlases = joinpath(celesteGraphics, "Atlases")

    storageXML = joinpath(storage, "XML")
    storageSprites = joinpath(storage, "Sprites")
    
    requiredFiles = (
        (joinpath(celesteGraphics, "ForegroundTiles.xml"), joinpath(storageXML, "ForegroundTiles.xml")),
        (joinpath(celesteGraphics, "BackgroundTiles.xml"), joinpath(storageXML, "BackgroundTiles.xml")),
        (joinpath(celesteGraphics, "AnimatedTiles.xml"), joinpath(storageXML, "AnimatedTiles.xml")),
        (joinpath(celesteGraphics, "Sprites.xml"), joinpath(storageXML, "Sprites.xml")),
        (joinpath(celesteGraphics, "Portraits.xml"), joinpath(storageXML, "Portraits.xml")),
    
        (joinpath(celesteAtlases, "Gameplay.meta"), joinpath(storageSprites, "Gameplay.meta")),
        (joinpath(celesteAtlases, "Gui.meta"), joinpath(storageSprites, "Gui.meta")),
        (joinpath(celesteAtlases, "Portraits.meta"), joinpath(storageSprites, "Portraits.meta")),
        (joinpath(celesteAtlases, "Misc.meta"), joinpath(storageSprites, "Misc.meta"))
    )

    requiredAtlases = (
        (joinpath(celesteAtlases, "Gameplay0.data"), joinpath(storageSprites, "Gameplay.png")),
        (joinpath(celesteAtlases, "Gui0.data"), joinpath(storageSprites, "Gui.png"))
    )

    gameplaySprites = joinpath(storage, "Gameplay.png")
    
    needsInclude = any(Bool[needsExtraction(from, to, force) for (from, to) in requiredAtlases])    

    if needsInclude
        include(Ahorn.abs"extract_sprites_images.jl")
    end

    for (from, to) in requiredAtlases
        if needsExtraction(from, to, force)
             # Making sure the method just loaded is used.
            Base.invokelatest(dumpSprites, from, to)
        end
    end

    for (from, to) in requiredFiles
        if needsExtraction(from, to, force)
            mkpath(dirname(to))

            cp(from, to, force=true)
        end
    end
end
