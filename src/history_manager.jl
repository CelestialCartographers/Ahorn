module History

using Gtk, Gtk.ShortNames
using Maple
using ..Ahorn

include("history.jl")

struct RoomSnapshot <: Snapshot
    description::String
    room::Maple.Room
    layers::Array{String, 1}

    RoomSnapshot(description::String, room::Maple.Room, layers::Array{String, 1}=String[]) = new(description, deepcopy(room), layers)
end

struct SelectionSnapshot <: Snapshot
    description::String
    room::Maple.Room
    selections::Set{Tuple{String, Ahorn.Rectangle, Any, Number}}

    SelectionSnapshot(description::String, room::Maple.Room, selections::Set{Tuple{String, Ahorn.Rectangle, Any, Number}}) = new(description, room, deepcopy(selections))
end

struct MultiSnapshot <: Snapshot
    description::String
    snapshots::Array{Snapshot, 1}
end

function MapSnapshot(description::String, map::Maple.Map)
    snapshots = Snapshot[]

    for room in map.rooms
        push!(snapshots, RoomSnapshot("Map backup", room))
    end

    selections = getToolSelections()
    if Ahorn.loadedState.room !== nothing && isa(selections, Set)
        push!(snapshots, SelectionSnapshot("Map backup", Ahorn.loadedState.room, selections))
    end

    return MultiSnapshot(description, snapshots)
end

function restoreSnapshot!(map::Maple.Map, snapshot::SelectionSnapshot)
    return Ahorn.eventToModule(Ahorn.currentTool, "setSelections", map, snapshot.room, snapshot.selections)
end

function restoreSnapshot!(map::Maple.Map, snapshot::RoomSnapshot)
    room = Maple.getRoomByName(map, snapshot.room.name)

    if isa(room, Maple.Room)
        for n in fieldnames(typeof(room))
            setfield!(room, n, deepcopy(getfield(snapshot.room, n)))
        end

    else
        room = deepcopy(snapshot.room)
        push!(map.rooms, room)
    end

    dr = Ahorn.getDrawableRoom(map, room)
    for layer in dr.layers
        if layer.name in snapshot.layers || isempty(snapshot.layers)
            layer.redraw = true
        end
    end

    Ahorn.draw(Ahorn.canvas)
end

function restoreSnapshot!(map::Maple.Map, snapshot::MultiSnapshot)
    for s in snapshot.snapshots
        restoreSnapshot!(map, s)
    end
end

function getToolSelections()
    selectionRes = Ahorn.eventToModule(Ahorn.currentTool, "getSelections") 
    if isa(selectionRes, Set)
        return deepcopy(selectionRes)
    end

    return Set{Tuple{String, Ahorn.Rectangle, Any, Number}}()
end

historyTimelines = Dict{Maple.Map, HistoryTimeline}()

currentMap() = Ahorn.loadedState.map

function getHistory(map::Maple.Map)
    if !haskey(historyTimelines, map)
        historyTimelines[map] = HistoryTimeline()
    end

    return historyTimelines[map]
end

function undo!(map::Maple.Map=currentMap())
    res = false
    Ahorn.eventToModule(Ahorn.currentTool, "beforeUndo", map)

    history = getHistory(map)
    if history.index > 0
        if history.index == length(history.snapshots)
            push!(history.snapshots, MapSnapshot("Map backup", map))
        end

        history.skip = true
        snapshot = pop!(history)
        @Ahorn.catchall restoreSnapshot!(map, snapshot)
        res = true
    end

    Ahorn.eventToModule(Ahorn.currentTool, "afterUndo", map)

    return res
end

function redo!(map::Maple.Map=currentMap())
    res = false
    Ahorn.eventToModule(Ahorn.currentTool, "beforeRedo", map)

    history = getHistory(map)

    if history.skip
        history.skip = false
        history.index += 1
    end

    if history.index < length(history.snapshots)
        history.index += 1
        snapshot = history.snapshots[history.index]

        if history.index == length(history.snapshots)
            pop!(history.snapshots)
            history.index -= 1
        end

        @Ahorn.catchall restoreSnapshot!(map, snapshot)
        res = true
    end

    Ahorn.eventToModule(Ahorn.currentTool, "afterRedo", map)

    return res
end

function undo!(widget::Ahorn.MenuItemsTypes)
    if !undo!()
        info_dialog("Cannot undo.\nStart of history.", Ahorn.window)
    end
end

function redo!(widget::Ahorn.MenuItemsTypes)
    if !redo!()
        info_dialog("Cannot redo.\nEnd of history.", Ahorn.window)
    end
end

function addSnapshot!(snapshot::Snapshot, map::Maple.Map=currentMap())
    history = getHistory(map)
    push!(history, snapshot)
end

end