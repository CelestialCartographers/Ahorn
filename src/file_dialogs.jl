function showFileOpenDialog(leaf::Gtk.GtkMenuItemLeaf=MenuItem())
    filename = open_dialog("Select map binary", window, tuple("*.bin"))

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
    filename = save_dialog("Save as", window)

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

saveFile(m::Map, filename::String) = encodeMap(m, filename)