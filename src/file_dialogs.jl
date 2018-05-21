# cd() is a workaround to set the default directory 
function showFileOpenDialog(leaf::Gtk.GtkMenuItemLeaf=MenuItem())
    celesteDir = config["celeste_dir"]
    mapsDir = joinpath(celesteDir, "ModContent", "Maps")

    if isdir(celesteDir)
        if !isdir(mapsDir)
            mkpath(mapsDir)
        end

        cd(mapsDir)
    end

    filename = ""
    cd(mapsDir) do
        filename = open_dialog("Select map binary", window, tuple("*.bin"))
    end

    # Did we actually select a file?
    if filename != ""
        global loadedFilename = filename
        global loadedMap = loadMap(filename)
        global selectedRoom = nothing
        global loadedRoom = nothing
        
        packageName = loadedMap.package

        updateTreeView!(roomList, getTreeData(loadedMap))

        setproperty!(window, :title, "$baseTitle - $packageName")

        draw(canvas)
    end
end

# save_dialog only warns on overwrite, but will ONLY return the filename
function showFileSaveDialog(leaf::Gtk.GtkMenuItemLeaf=MenuItem())
    celesteDir = config["celeste_dir"]
    mapsDir = joinpath(celesteDir, "ModContent", "Maps")

    if isdir(celesteDir)
        if !isdir(mapsDir)
            mkpath(mapsDir)
        end

    end

    filename = ""
    cd(mapsDir) do
        filename = save_dialog("Save as", window)
    end

    if filename != ""
        global loadedFilename = filename
        
        saveFile(loadedMap, filename)
    end
end

function menuFileSave(leaf::Gtk.GtkMenuItemLeaf=MenuItem())
    if loadedFilename === nothing || loadedFilename == ""
        showFileSaveDialog(leaf)

    else
        saveFile(loadedMap, loadedFilename)
    end
end

saveFile(m::Map, filename::String) = splitext(filename)[2] == ".bin"? encodeMap(m, filename) : encodeMap(m, filename * ".bin")