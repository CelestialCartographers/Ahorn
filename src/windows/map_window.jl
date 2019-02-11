function createNewMap(widget=nothing)
    button, name = input_dialog("Enter package name for new map", "11-Example", (("Cancel", 0), ("Create Map", 1)), window)

    dialogText = "You might have unsaved changes in your map.\nPlease confirm that you want to create the new map '$name'."
    res = button == 1 && (Ahorn.loadedState.lastSavedHash == hash(Ahorn.loadedState.side) || ask_dialog(dialogText, Ahorn.window))

    if button == 1 && res
        # Clear render cache from last map
        if loadedState.map !== nothing && get(config, "clear_render_cache_on_map_load", true)
            deleteDrawableRoomCache(loadedState.map)
        end

        loadedState.filename = ""
        loadedState.roomName = ""
        loadedState.room = nothing

        loadedState.map = Map(name)
        loadedState.side = Side(loadedState.map, Dict{String, Any}())
        
        updateTreeView!(roomList, getTreeData(loadedState.map))
        
        GAccessor.title(window, "$baseTitle - $name")

        draw(canvas)
    end
end