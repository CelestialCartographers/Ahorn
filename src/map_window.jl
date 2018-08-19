function createNewMap(widget)
    button, name = input_dialog("Enter package name for new map", "11-Example", (("Cancel", 0), ("Create Map", 1)), window)

    if button == 1
        # Clear render cache from last map
        if loadedState.map !== nothing && get(config, "clear_render_cache_on_map_load", true)
            deleteDrawableRoomCache(loadedState.map)
        end

        loadedState.filename = ""
        loadedState.roomName = ""
        loadedState.room = nothing

        loadedState.map = Map(name)
        loadedState.side = Side(loadedState.map, Dict{String, Any}(
            "meta" => Dict{String, Any}(
                "Name" => name
            )
        ))
        
        updateTreeView!(roomList, getTreeData(loadedState.map))
        
        setproperty!(window, :title, "$baseTitle - $name")

        draw(canvas)
    end
end