mutable struct LoadedState
    roomName::String
    filename::String
    room::Union{Maple.Room, Void}
    map::Union{Maple.Map, Void}
    lastSavedMap::Union{Maple.Map, Void}
end

function LoadedState(roomName::String, filename::String)
    map = nothing
    room = nothing

    if isfile(filename)
        map = loadMap(filename)
        room = getRoomByName(map, roomName)
    end

    return LoadedState(roomName, filename, isa(room, Maple.Room)? room : nothing, map, deepcopy(map))
end