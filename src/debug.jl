module debug

using ..Ahorn

config = Dict{String, Any}()

function setConfig(fn::String, buffertime::Int=0)
    global config = Ahorn.loadConfig(fn, buffertime)
end

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
    Ahorn.loadModule.(Ahorn.loadedTools)
    Ahorn.loadExternalModules!(Ahorn.loadedModules, Ahorn.loadedTools, "tools")
    Ahorn.changeTool!(Ahorn.loadedTools[1])
    Ahorn.select!(Ahorn.roomList, row -> row[1] == Ahorn.loadedState.roomName)

    return true
end

function reloadEntities!()
    dr = Ahorn.getDrawableRoom(Ahorn.loadedState.map, Ahorn.loadedState.room)

    Ahorn.loadModule.(Ahorn.loadedEntities)
    Ahorn.loadExternalModules!(Ahorn.loadedModules, Ahorn.loadedEntities, "entities")
    Ahorn.registerPlacements!(Ahorn.entityPlacements, Ahorn.loadedEntities)

    Ahorn.getLayerByName(dr.layers, "entities").redraw = true
    Ahorn.select!(Ahorn.roomList, row -> row[1] == Ahorn.loadedState.roomName)

    empty!(Ahorn.entityNameLookup)

    return true
end

function reloadTriggers!()
    dr = Ahorn.getDrawableRoom(Ahorn.loadedState.map, Ahorn.loadedState.room)

    Ahorn.loadModule.(Ahorn.loadedTriggers)
    Ahorn.loadExternalModules!(Ahorn.loadedModules, Ahorn.loadedTriggers, "triggers")
    Ahorn.registerPlacements!(Ahorn.triggerPlacements, Ahorn.loadedTriggers)

    Ahorn.getLayerByName(dr.layers, "triggers").redraw = true
    Ahorn.select!(Ahorn.roomList, row -> row[1] == Ahorn.loadedState.roomName)

    return true
end

function clearMapDrawingCache!(map::Ahorn.Maple.Map=Ahorn.loadedState.map)
    Ahorn.deleteDrawableRoomCache(map)
    Ahorn.draw(Ahorn.canvas)

    return true
end

function forceDrawWholeMap!(map::Ahorn.Maple.Map=Ahorn.loadedState.map)
    ctx = Ahorn.Gtk.getgc(Ahorn.canvas)

    for room in map.rooms
        dr = Ahorn.getDrawableRoom(map, room)

        Ahorn.drawRoom(ctx, Ahorn.camera, dr, alpha=1.0)
    end

    Ahorn.draw(Ahorn.canvas)

    return true
end

end