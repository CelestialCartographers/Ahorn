mutable struct LoadedState
    roomName::String
    filename::String
    room::Union{Maple.Room, Nothing}
    side::Union{Maple.Side, Nothing}
    map::Union{Maple.Map, Nothing}
    lastSavedHash::Unsigned
end

function LoadedState(roomName::String, filename::String)
    side = nothing
    map = nothing
    room = nothing

    if isfile(filename)
        side = loadSide(filename)
        map = side.map
        room = getRoomByName(map, roomName)

        if map !== nothing
            EntityIds.updateValidIds(map)
        end
    end

    return LoadedState(roomName, filename, isa(room, Maple.Room) ? room : nothing, side, map, hash(side))
end