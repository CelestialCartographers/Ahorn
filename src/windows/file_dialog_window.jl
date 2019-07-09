function lastMapDir()
    celesteDir = config["celeste_dir"]
    mapsDir = joinpath(celesteDir, "Mods")
    lastDir = dirname(get(persistence, "files_lastfile", mapsDir))
    targetDir = ispath(lastDir) ? lastDir : mapsDir
    targetDir = ispath(targetDir) ? targetDir : pwd()

    return targetDir
end

function showFileOpenDialog(leaf::Ahorn.MenuItemsTypes=MenuItem(), folder::String=lastMapDir())
    @Ahorn.catchall begin
        filename = openDialog("Select map binary", window, ["*.bin"], folder=folder)

        # Did we actually select a file?
        if filename != ""
            dialogText = "You might have unsaved changes in your map.\nPlease confirm that you want to load '$filename'."
            res = loadedState.lastSavedHash == hash(loadedState.side) || ask_dialog(dialogText, window)

            if res
                # Clear render cache from last map
                if loadedState.map !== nothing && get(config, "clear_render_cache_on_map_load", true)
                    deleteDrawableRoomCache(loadedState.map)
                end

                loadedState.filename = filename
                loadedState.side = loadSide(filename)
                loadedState.map = loadedState.side.map
                loadedState.lastSavedHash = hash(loadedState.side)
                loadedState.roomName = ""
                loadedState.room = nothing

                persistence["files_lastroom"] = loadedState.roomName
                persistence["files_lastfile"] = loadedState.filename
                
                packageName = loadedState.map.package

                EntityIds.updateValidIds(loadedState.map)

                loadXMLMeta()

                updateTreeView!(roomList, getTreeData(loadedState.map), 1)
                handleRoomChanged(loadedState.map, loadedState.room)

                GAccessor.title(window, "$baseTitle - $(Maple.getSideName(loadedState.side))")

                draw(canvas)

                return true
            end
        end
    end

    return false
end

# saveDialog warns on overwrite, but only returns the filename
function showFileSaveDialog(leaf::Ahorn.MenuItemsTypes=MenuItem())
    targetDir = lastMapDir()
    filename = saveDialog("Save as", window, ["*.bin"], folder=targetDir)

    if filename != ""
        loadedState.filename = filename
        persistence["files_lastfile"] = loadedState.filename
        
        saveFile(loadedState.side, filename)

        return true
    end

    return false
end

function menuFileSave(leaf::Ahorn.MenuItemsTypes=MenuItem())
    if loadedState.filename === nothing || loadedState.filename == ""
        showFileSaveDialog(leaf)

    else
        saveFile(loadedState.side, loadedState.filename)
    end
end

function saveFile(side::Side, filename::String)
    try
        PreSaveSanitizers.sortRoomNames(side, config)
        PreSaveSanitizers.warnMissingDecals(side, config)
        PreSaveSanitizers.warnDuplicateIds(side, config)

        loadedState.lastSavedHash = hash(side)

        fn = hasExt(filename, ".bin") ? filename : filename * ".bin"
        encodeSide(side, fn)

    catch e
        println(Base.stderr, e)
        info_dialog("Failed to save map.", Ahorn.window)
    end
end