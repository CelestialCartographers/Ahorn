module History

using Gtk, Gtk.ShortNames
using Maple

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
    selections::Set{Tuple{String, Main.Rectangle, Any, Number}}

    SelectionSnapshot(description::String, room::Maple.Room, selections::Set{Tuple{String, Main.Rectangle, Any, Number}}) = new(description, room, deepcopy(selections))
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

    success, selections = getToolSelections()
    if success
        println("Selections for map")
        push!(snapshots, SelectionSnapshot("Map backup", Main.loadedState.room, selections))
    end

    return MultiSnapshot(description, snapshots)
end

function restoreSnapshot!(map::Maple.Map, snapshot::SelectionSnapshot)
    return Main.eventToModule(Main.currentTool, "setSelections", map, snapshot.room, snapshot.selections)
end

function restoreSnapshot!(map::Maple.Map, snapshot::RoomSnapshot)
    room = Maple.getRoomByName(map, snapshot.room.name)

    if isa(room, Maple.Room)
        for n in fieldnames(room)
            setfield!(room, n, deepcopy(getfield(snapshot.room, n)))
        end

    else
        room = deepcopy(snapshot.room)
        push!(map.rooms, room)
    end

    dr = Main.getDrawableRoom(map, room)
    for layer in dr.layers
        if layer.name in snapshot.layers || isempty(snapshot.layers)
            layer.redraw = true
        end
    end

    Main.draw(Main.canvas)
end

function restoreSnapshot!(map::Maple.Map, snapshot::MultiSnapshot)
    for s in snapshot.snapshots
        restoreSnapshot!(map, s)
    end
end

function getToolSelections()
    selectionRes = Main.eventToModule(Main.currentTool, "getSelections") 
    if isa(selectionRes, Tuple)
        success, selections = selectionRes

        if success
            return true, deepcopy(selections)
        end
    end

    return false, Set{Tuple{String, Main.Rectangle, Any, Number}}()
end

historyTimelines = Dict{Maple.Map, HistoryTimeline}()

currentMap() = Main.loadedState.map

function getHistory!(map::Main.Map)
    if !haskey(historyTimelines, map)
        historyTimelines[map] = HistoryTimeline()
    end

    return historyTimelines[map]
end

function undo!(map::Maple.Map=currentMap())
    res = false
    Main.eventToModule(Main.currentTool, "beforeUndo", map)

    history = getHistory!(map::Main.Map)
    if history.index > 0
        if history.index == length(history.snapshots)
            push!(history.snapshots, MapSnapshot("Map backup", map))
        end

        history.skip = true
        snapshot = pop!(history)
        restoreSnapshot!(map, snapshot)
        res = true
    end

    Main.eventToModule(Main.currentTool, "afterUndo", map)

    return res
end

function redo!(map::Maple.Map=currentMap())
    res = false
    Main.eventToModule(Main.currentTool, "beforeRedo", map)

    history = getHistory!(map::Main.Map)

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

        restoreSnapshot!(map, snapshot)
        res = true
    end

    Main.eventToModule(Main.currentTool, "afterRedo", map)

    return res
end

function undo!(widget::Gtk.GtkMenuItemLeaf)
    if !undo!()
        info_dialog("Cannot undo.\nStart of history.", Main.window)
    end
end

function redo!(widget::Gtk.GtkMenuItemLeaf)
    if !redo!()
        info_dialog("Cannot redo.\nEnd of history.", Main.window)
    end
end

function addSnapshot!(snapshot::Snapshot, map::Maple.Map=currentMap())
    history = getHistory!(map::Main.Map)
    push!(history, snapshot)
end

end