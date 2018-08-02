mutable struct LoadedState
    roomName::String
    filename::String
    room::Union{Maple.Room, Void}
    side::Union{Maple.Side, Void}
    map::Union{Maple.Map, Void}
    lastSavedMap::Union{Maple.Map, Void}
end

function LoadedState(roomName::String, filename::String)
    side = nothing
    map = nothing
    room = nothing

    if isfile(filename)
        side = loadSide(filename)
        map = side.map
        room = getRoomByName(map, roomName)
    end

    return LoadedState(roomName, filename, isa(room, Maple.Room)? room : nothing, side, map, deepcopy(map))
end