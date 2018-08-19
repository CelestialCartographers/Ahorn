function showFileOpenDialog(leaf::Gtk.GtkMenuItemLeaf=MenuItem())
    celesteDir = config["celeste_dir"]
    mapsDir = joinpath(celesteDir, "Mods")
    lastDir = dirname(get(persistence, "files_lastfile", mapsDir))
    targetDir = ispath(lastDir)? lastDir : mapsDir

    filename = ""
    cd(targetDir) do
        filename = openDialog("Select map binary", window, ["*.bin"])
    end

    # Did we actually select a file?
    if filename != ""
        dialogText = "You might have unsaved changes in your map.\nPlease confirm that you want to load '$filename'."
        res = isequal(loadedState.lastSavedMap, loadedState.map) || ask_dialog(dialogText, window)

        if res
            # Clear render cache from last map
            if loadedState.map !== nothing && get(config, "clear_render_cache_on_map_load", true)
                deleteDrawableRoomCache(loadedState.map)
            end

            loadedState.filename = filename
            loadedState.side = loadSide(filename)
            loadedState.map = loadedState.side.map
            loadedState.lastSavedMap = deepcopy(loadedState.map)
            loadedState.roomName = ""
            loadedState.room = nothing

            persistence["files_lastroom"] = loadedState.roomName
            persistence["files_lastfile"] = loadedState.filename
            
            packageName = loadedState.map.package

            updateTreeView!(roomList, getTreeData(loadedState.map), 1)

            setproperty!(window, :title, "$baseTitle - $(Maple.getSideName(loadedState.side))")

            draw(canvas)
        end
    end
end

# save_dialog only warns on overwrite, but will ONLY return the filename
function showFileSaveDialog(leaf::Gtk.GtkMenuItemLeaf=MenuItem())
    celesteDir = config["celeste_dir"]
    mapsDir = joinpath(celesteDir, "Mods")
    lastDir = dirname(get(persistence, "files_lastfile", mapsDir))
    targetDir = ispath(lastDir)? lastDir : mapsDir

    filename = ""
    cd(targetDir) do
        filename = saveDialog("Save as", window, ["*.bin"])
    end

    if filename != ""
        loadedState.filename = filename
        persistence["files_lastfile"] = loadedState.filename
        
        saveFile(loadedState.side, filename)
    end
end

function menuFileSave(leaf::Gtk.GtkMenuItemLeaf=MenuItem())
    if loadedState.filename === nothing || loadedState.filename == ""
        showFileSaveDialog(leaf)

    else
        saveFile(loadedState.side, loadedState.filename)
    end
end

function saveFile(side::Side, filename::String)
    map = side.map
    sortRoomNames = get(config, "sort_rooms_on_save", true)

    if sortRoomNames
        sort!(map.rooms, by=r -> r.name)
        updateTreeView!(roomList, getTreeData(map), row -> row[1] == loadedState.roomName)
    end

    loadedState.lastSavedMap = deepcopy(map)

    fn = hasExt(filename, ".bin")? filename : filename * ".bin"
    encodeSide(side, fn)
end