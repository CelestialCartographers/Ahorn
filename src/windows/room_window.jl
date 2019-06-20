module RoomWindow

using Gtk, Gtk.ShortNames, Gtk.GConstants
using ..Ahorn, Maple

roomWindow = nothing
templateRoom = Maple.Room(name="1")

currentRoom = nothing
minimumRecommended = (320, 184)

roomFieldOrder = String[
    "name", "musicProgress", "x", "y",
    "width", "height", "underwater", "space",
    "disableDownTransition", "checkpoint", "dark", "whisper",
    "musicLayer1", "musicLayer2", "musicLayer3", "musicLayer4",
    "music", "windPattern", "color"
]

dropdownOptions = Dict{String, Any}(
    "music" => sort(collect(keys(Maple.Songs.songs))),
    "windPattern" => sort(Maple.wind_patterns)
)

# Symbols reads and sets values on the room, other values are stored in data dict
fields = Dict{String, Any}(
    "checkpoint" => (room, simple) -> findfirst(e -> e.name == "checkpoint", room.entities) != nothing,

    "width" => (room, simple) -> round(Int, room.size[1] / (simple ? 8 : 1)),
    "height" => (room, simple) -> round(Int, room.size[2] / (simple ? 8 : 1)),

    "x" => (room, simple) -> round(Int, room.position[1] / (simple ? 8 : 1)),
    "y" => (room, simple) -> round(Int, room.position[2] / (simple ? 8 : 1)),

    "name" => :name,

    "musicLayer1" => :musicLayer1,
    "musicLayer2" => :musicLayer2,
    "musicLayer3" => :musicLayer3,
    "musicLayer4" => :musicLayer4,

    "dark" => :dark,
    "space" => :space,
    "underwater" => :underwater,
    "whisper" => :whisper,

    "disableDownTransition" => :disableDownTransition,

    "color" => :color,

    "music" => :music,
    "musicProgress" => :musicProgress,

    "windPattern" => :windPattern
)

function getValue(room::Maple.Room, value::Any, simple::Bool)
    if isa(value, Symbol)
        return getfield(room, value)

    elseif isa(value, Function)
        return value(room, simple)

    else
        return value
    end
end

function getOptions(room::Maple.Room, dropdownOptions::Dict{String, Any}, langdata::Ahorn.LangData, simple::Bool=get(Ahorn.config, "use_simple_room_values", true))
    res = Ahorn.Form.Option[]

    names = get(langdata, :names)
    tooltips = get(langdata, :tooltips)

    for (dataName, symbol) in fields
        symbolDataName = Symbol(dataName)
        keyOptions = get(dropdownOptions, dataName, nothing)
        displayName = haskey(names, symbolDataName) ? names[symbolDataName] : Ahorn.humanizeVariableName(dataName)
        tooltip = Ahorn.expandTooltipText(get(tooltips, symbolDataName, ""))
        value = getValue(room, symbol, simple)

        push!(res, Ahorn.Form.suggestOption(displayName, value, tooltip=tooltip, dataName=dataName, choices=keyOptions, editable=true))
    end

    return res
end

function createCheckpoint(room::Maple.Room)
    for entity in room.entities
        if entity.name == "player"
            x, y = Int(get(entity.data, "x", 0)), Int(get(entity.data, "y", 0))

            return Maple.ChapterCheckpoint(x, y, allowOrigin=true)
        end
    end

    return Maple.ChapterCheckpoint(Int.(room.size ./ 2)..., allowOrigin=true)
end

# Remove all instances of checkpoints
# Add new one if the room should have one
function handleCheckpoint!(room::Maple.Room, add::Bool=false)
    filter!(e -> e.name != "checkpoint", room.entities)

    if add
        push!(room.entities, createCheckpoint(room))
    end
end

function handleSimpleValues!(data::Dict{String, Any}, simple::Bool=get(Ahorn.config, "use_simple_room_values", true))
    if simple
        data["x"] *= 8
        data["y"] *= 8

        data["width"] *= 8
        data["height"] *= 8
    end
end

function handleFakeKeys!(data::Dict{String, Any})
    data["position"] = (data["x"], data["y"])
    data["size"] = (data["width"], data["height"])

    signs = sign.(data["size"]) .== -1
    data["size"] = abs.(data["size"])
    data["position"] = data["position"] .- data["size"] .* signs
end

function handleMusicTrack(data::Dict{String, Any}, parent::Gtk.GtkWindow=Ahorn.window)
    if data["music"] != "" && !(data["music"] in dropdownOptions["music"]) && !startswith(data["music"], "event:/") 
        info_dialog("You have entered an invalid song name.\nIf you're using a custom song, make sure to copy the event path from FMOD Studio, which starts with 'event:/'", parent)

        return true
    end

    return false
end

function handleRoomSize(data::Dict{String, Any}, simple::Bool=get(Ahorn.config, "use_simple_room_values", true), parent::Gtk.GtkWindow=Ahorn.window)
    minimumRecommendedDisplay = (floor(Int, 320 / (simple ? 8 : 1)), floor(Int, 184 / (simple ? 8 : 1)))
    if any(data["size"] .< minimumRecommended)
        if !ask_dialog("The size you have chosen is smaller than the recommended minimum size $minimumRecommended.\nAre you sure you want this size?", parent)
            return true
        end
    end

    return false
end

function handleRoomName(data::Dict{String, Any}, map::Maple.Map, creating::Bool=true, parent::Gtk.GtkWindow=Ahorn.window)
    exists = isa(Maple.getRoomByName(map, data["name"]), Maple.Room)

    if exists && creating
        info_dialog("The selected room name is already in use.", parent)

        return true
    end

    return false
end

function handleRoomValues!(room::Maple.Room, data::Dict{String, Any})
    structFields = fieldnames(typeof(room))

    for symbol in structFields
        name = string(symbol)

        if haskey(data, name)
            setfield!(room, symbol, data[name])
        end
    end
end

function markForRedraw(room::Maple.Room, map::Maple.Map)
    dr = Ahorn.getDrawableRoom(map, room)

    for layer in dr.layers
        layer.redraw = true
    end
end

function updateTemplateRoom(creating::Bool=true)
        # Copy all fields from the selected room if we are creating new one
        if creating && Ahorn.loadedState.room !== nothing
            global templateRoom = deepcopy(Ahorn.loadedState.room)
        end

        global currentRoom = creating ? templateRoom : Ahorn.loadedState.room
end

function createRoomWindow(creating::Bool=true, simple::Bool=get(Ahorn.config, "use_simple_room_values", true))
    if Ahorn.loadedState.map === nothing
        info_dialog("No map is currently loaded.", Ahorn.window)

    elseif !creating && Ahorn.loadedState.room == nothing
        info_dialog("Cannot edit non existing room.", Ahorn.window)

    else
        updateTemplateRoom(creating)
        title = creating ? "$(Ahorn.baseTitle) - Create Room" : "$(Ahorn.baseTitle) - $(currentRoom.name)"

        langdata = get(Ahorn.langdata, :room_window)
        options = getOptions(currentRoom, dropdownOptions, langdata)
        section = Ahorn.Form.Section("Room", options, fieldOrder=roomFieldOrder)
        buttonText = creating ? "Add Room" : "Update Room"

        function callback(data::Dict{String, Any})
            updateTemplateRoom(creating)
            currentMap = Ahorn.loadedState.map

            handleSimpleValues!(data, simple)
            handleFakeKeys!(data)
            
            exitEarly = handleRoomSize(data, simple, roomWindow) ||
                handleMusicTrack(data, roomWindow) ||
                handleRoomName(data, currentMap, creating, roomWindow)

            if exitEarly
                return false
            end

            snapshotDesc = (creating ? "Created room" : "Updated room ") * data["name"]
            Ahorn.History.addSnapshot!(Ahorn.History.MapSnapshot(snapshotDesc, currentMap))

            handleCheckpoint!(currentRoom, data["checkpoint"])
            handleRoomValues!(currentRoom, data)

            if creating
                # Remove values so we don't create a carbon copy of the room
                empty!(currentRoom.fgDecals)
                empty!(currentRoom.bgDecals)

                empty!(currentRoom.triggers)
                empty!(currentRoom.entities)

                currentRoom.fgTiles.data .= '0'
                currentRoom.bgTiles.data .= '0'
                currentRoom.objTiles.data .= -1

                push!(currentMap.rooms, currentRoom)
            end

            Maple.updateTileSize!(currentRoom, Maple.tile_fg_names["Air"], Maple.tile_fg_names["Air"])
            Ahorn.updateTreeView!(Ahorn.roomList, Ahorn.getTreeData(currentMap), row -> row[1] == currentRoom.name)

            markForRedraw(currentRoom, currentMap)
            draw(Ahorn.canvas)

            return true
        end

        if roomWindow !== nothing
            Gtk.destroy(roomWindow)
        end

        return global roomWindow = Ahorn.Form.createFormWindow(title, section, callback=callback, buttonText=buttonText)
    end
end

createRoom(widget::Union{Ahorn.MenuItemsTypes, Nothing}=nothing) = showall(createRoomWindow(true))
configureRoom(widget::Union{Ahorn.MenuItemsTypes, Nothing}=nothing) = showall(createRoomWindow(false))

function roomNameValidator(s::String)
    if Ahorn.loadedState.map === nothing || currentRoom === nothing
        return false
    end

    room = Maple.getRoomByName(Ahorn.loadedState.map, s)

    return s != "" && (s == currentRoom.name || !isa(room, Maple.Room))
end

end