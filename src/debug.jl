module debug

configFilename = joinpath(Main.storageDirectory, "debug.json")
config = Main.loadConfig(configFilename, 0)

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

function reloadTools!()
    Main.loadModule.(Main.loadedTools)
    Main.changeTool!(Main.loadedTools[1])
    Main.select!(Main.roomList, row -> row[1] == Main.loadedState.roomName)

    return true
end

function reloadEntities!()
    dr = Main.getDrawableRoom(Main.loadedState.map, Main.loadedState.room)

    Main.loadModule.(Main.loadedEntities)
    Main.registerPlacements!(Main.entityPlacements, Main.loadedEntities)

    Main.getLayerByName(dr.layers, "entities").redraw = true
    Main.select!(Main.roomList, row -> row[1] == Main.loadedState.roomName)

    return true
end

function reloadTriggers!()
    dr = Main.getDrawableRoom(Main.loadedState.map, Main.loadedState.room)

    Main.loadModule.(Main.loadedTriggers)
    Main.registerPlacements!(Main.triggerPlacements, Main.loadedTriggers)

    Main.getLayerByName(dr.layers, "triggers").redraw = true
    Main.select!(Main.roomList, row -> row[1] == Main.loadedState.roomName)

    return true
end

function redrawAllRooms!(map::Main.Maple.Map=Main.loadedState.map)
    # Make sure to destroy all surfaces properly
    rooms = Main.getDrawableRooms(map)
    for room in rooms
        Main.destroy(room)
    end

    delete!(Main.drawableRooms, map)

    Main.draw(Main.canvas)

    return true
end

end