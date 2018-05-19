module RoomWindow

using Gtk, Gtk.ShortNames, Gtk.GConstants
using Maple

roomWindow = nothing
templateRoom = Maple.Room()

songList = collect(keys(Maple.Songs.songs))
windPatterns = Maple.windpatterns
sort!(songList)

function initCombolBox!(widget, list)
    push!.(widget, list)
    setproperty!(widget, :active, 0)
end

function updateRoomFromFields!(map::Maple.Map, room::Maple.Room, configuring::Bool=false)
    try
        if Main.loadedMap != nothing
            roomName = getproperty(roomTextfield, :text, String)
            roomExists = Maple.getRoomByName(map, roomName)

            if !configuring && isa(roomExists, Maple.Room)
                return false, "A room with name '$roomName' already exists."
            end

            room.name = getproperty(roomTextfield, :text, String)

            room.size = (
                parse(Int, getproperty(widthTextfield, :text, String)),
                parse(Int, getproperty(heightTextfield, :text, String))
            )

            room.position = (
                parse(Int, getproperty(posXTextfield, :text, String)),
                parse(Int, getproperty(posYTextfield, :text, String))
            )

            if any(room.size .< (320, 184))
                if !ask_dialog("The room you have selected is smaller than the recommended minimum size (320, 184).\nAre you sure you want this size?", roomWindow)
                    return false, false
                end
            end

            room.musicLayer1 = getproperty(musicLayer1CheckBox, :active, Bool)
            room.musicLayer2 = getproperty(musicLayer2CheckBox, :active, Bool)
            room.musicLayer3 = getproperty(musicLayer3CheckBox, :active, Bool)
            room.musicLayer4 = getproperty(musicLayer4CheckBox, :active, Bool)

            room.dark = getproperty(darkCheckBox, :active, Bool)
            room.space = getproperty(spaceCheckBox, :active, Bool)
            room.underwater = getproperty(underwaterCheckBox, :active, Bool)
            room.whisper = getproperty(whisperCheckBox, :active, Bool)

            room.music = get(songList, getproperty(musicCombo, :active, Int) + 1, "music_oldsite")
            room.windPattern = get(windPatterns, getproperty(windPatternCombo, :active, Int) + 1, "None")

            return true, "OK"
        end

    catch e
        return false, "Some of the inputs you have made might be incorrect."
    end
end

function setFieldsFromRoom(room::Maple.Room)
    setproperty!(roomTextfield, :text, room.name)

    width, height = room.size
    setproperty!(widthTextfield, :text, string(width))
    setproperty!(heightTextfield, :text, string(height))

    x, y = room.position
    setproperty!(posXTextfield, :text, string(x))
    setproperty!(posYTextfield, :text, string(y))

    setproperty!(darkCheckBox, :active, room.dark)
    setproperty!(spaceCheckBox, :active, room.space)
    setproperty!(underwaterCheckBox, :active, room.underwater)
    setproperty!(whisperCheckBox, :active, room.whisper)

    setproperty!(musicLayer1CheckBox, :active, room.musicLayer1)
    setproperty!(musicLayer2CheckBox, :active, room.musicLayer2)
    setproperty!(musicLayer3CheckBox, :active, room.musicLayer3)
    setproperty!(musicLayer4CheckBox, :active, room.musicLayer4)

    setproperty!(windPatternCombo, :active, findfirst(windPatterns, room.windPattern) - 1)
    setproperty!(musicCombo, :active, findfirst(songList, room.music) - 1)
end

function createRoomHandler(widget)
    room = Maple.Room()
    success, reason = updateRoomFromFields!(Main.loadedMap, room)

    if success
        Maple.updateTileSize!(room, Maple.tile_names["Air"], Maple.tile_names["Stone"])
        push!(Main.loadedMap.rooms, room)
        Main.updateTreeView!(Main.roomList, Main.getTreeData(Main.loadedMap), row -> row[1] == room.name)
        markForRedraw(room, Main.loadedMap)
        draw(Main.canvas)
        visible(roomWindow, false)

    else
        if isa(reason, String)
            warn_dialog(reason, roomWindow)
        end
    end
end

function spawnWindowIfAbsent!()
    if roomWindow === nothing
        global roomWindow = createWindow()
    end
end

function markForRedraw(room::Maple.Room, map::Maple.Map)
    dr = Main.getDrawableRoom(map, room)

    Main.getLayerByName(dr.layers, "fgTiles").redraw = true
    Main.getLayerByName(dr.layers, "bgTiles").redraw = true
    Main.getLayerByName(dr.layers, "fgParallax").redraw = true
    Main.getLayerByName(dr.layers, "bgParallax").redraw = true
end

function updateRoomHandler(widget)
    success, reason = updateRoomFromFields!(Main.loadedMap, Main.loadedRoom, true)

    if success
        Maple.updateTileSize!(Main.loadedRoom, Maple.tile_names["Air"], Maple.tile_names["Stone"])
        Main.updateTreeView!(Main.roomList, Main.getTreeData(Main.loadedMap), row -> row[1] == Main.loadedRoom.name)
        markForRedraw(Main.loadedRoom, Main.loadedMap)
        draw(Main.canvas)
        visible(roomWindow, false)

    else
        if isa(reason, String)
            warn_dialog(reason, roomWindow)
        end
    end
end

# Cleaner functions for gtk event callbacks
function showRoomWindow(widget=nothing, event=nothing)
    spawnWindowIfAbsent!()
    visible(roomWindow, true)

    return true
end

function hideRoomWindow(widget=nothing, event=nothing)
    spawnWindowIfAbsent!()
    visible(roomWindow, false)

    return true
end

function createRoom(widget::Gtk.GtkMenuItemLeaf=MenuItem())
    if Main.loadedMap === nothing
        info_dialog("No map is currently loaded.", Main.window)

    else
        spawnWindowIfAbsent!()

        setproperty!(roomWindow, :title, "$(Main.baseTitle) - Create Room")

        signal_handler_disconnect(roomCreationButton, roomButtonSignal)
        setproperty!(roomCreationButton, :label, "Create Room")
        global roomButtonSignal = signal_connect(createRoomHandler, roomCreationButton, "clicked")

        Gtk.GLib.@sigatom setFieldsFromRoom(templateRoom)

        visible(roomWindow, true)
    end
end

function configureRoom(widget::Gtk.GtkMenuItemLeaf=MenuItem())
    if Main.loadedMap != nothing && Main.loadedRoom != nothing
        spawnWindowIfAbsent!()

        setproperty!(roomWindow, :title, "$(Main.baseTitle) - $(Main.loadedRoom.name)")

        signal_handler_disconnect(roomCreationButton, roomButtonSignal)
        setproperty!(roomCreationButton, :label, "Update Room")
        global roomButtonSignal = signal_connect(updateRoomHandler, roomCreationButton, "clicked")

        Gtk.GLib.@sigatom setFieldsFromRoom(Main.loadedRoom)

        visible(roomWindow, true)
    end
end

# Create all the Gtk widgets
roomGrid = Grid()
roomTextfield = Entry()
widthTextfield = Entry()
heightTextfield = Entry()
posXTextfield = Entry()
posYTextfield = Entry()

darkCheckBox = CheckButton("Dark")
spaceCheckBox = CheckButton("Space")
underwaterCheckBox = CheckButton("Underwater")
whisperCheckBox = CheckButton("Whisper")

musicLayer1CheckBox = CheckButton("Music Layer 1")
musicLayer2CheckBox = CheckButton("Music Layer 2")
musicLayer3CheckBox = CheckButton("Music Layer 3")
musicLayer4CheckBox = CheckButton("Music Layer 4")

musicCombo = ComboBoxText()
windPatternCombo = ComboBoxText()

initCombolBox!(musicCombo, songList)
initCombolBox!(windPatternCombo, windPatterns)

roomLabel = Label("Room Name")
widthLabel = Label("Width")
heightLabel = Label("Height")
posXLabel = Label("X")
posYLabel = Label("Y")

windPatternLabel = Label("Wind Pattern")
musicLabel = Label("Music")

setproperty!(roomLabel, :xalign, 0.1)
setproperty!(widthLabel, :xalign, 0.1)
setproperty!(heightLabel, :xalign, 0.1)
setproperty!(posXLabel, :xalign, 0.1)
setproperty!(posYLabel, :xalign, 0.1)
setproperty!(windPatternLabel, :xalign, 0.1)
setproperty!(musicLabel, :xalign, 0.1)

roomCreationButton = Button("Create Room")

roomButtonSignal = signal_connect(createRoomHandler, roomCreationButton, "clicked")

roomGrid[1, 1] = roomLabel
roomGrid[2:4, 1] = roomTextfield

roomGrid[1, 2] = widthLabel
roomGrid[2, 2] = widthTextfield
roomGrid[3, 2] = heightLabel
roomGrid[4, 2] = heightTextfield

roomGrid[1, 3] = posXLabel
roomGrid[2, 3] = posXTextfield
roomGrid[3, 3] = posYLabel
roomGrid[4, 3] = posYTextfield

roomGrid[1, 4] = darkCheckBox
roomGrid[2, 4] = spaceCheckBox
roomGrid[3, 4] = underwaterCheckBox
roomGrid[4, 4] = whisperCheckBox

roomGrid[1, 5] = musicLayer1CheckBox
roomGrid[2, 5] = musicLayer2CheckBox
roomGrid[3, 5] = musicLayer3CheckBox
roomGrid[4, 5] = musicLayer4CheckBox

roomGrid[1, 6] = musicLabel
roomGrid[2, 6] = musicCombo
roomGrid[3, 6] = windPatternLabel
roomGrid[4, 6] = windPatternCombo

roomGrid[1:4, 7] = roomCreationButton

function createWindow()
    roomWindow = Window("$(Main.baseTitle) - New Room", -1, -1, false, icon = Main.windowIcon
    ) |> (Frame() |> (roomBox = Box(:v)))

    # Hide window instead of destroying it
    signal_connect(hideRoomWindow, roomWindow, "delete_event")
    
    push!(roomBox, roomGrid)
    showall(roomWindow)

    return roomWindow
end

end