module RoomWindow

using Gtk, Gtk.ShortNames, Gtk.GConstants
using Maple

roomWindow = nothing
templateRoom = Maple.Room(name="1")

songList = collect(keys(Maple.Songs.songs))
windPatterns = Maple.windpatterns
sort!(songList)

function initCombolBox!(widget, list)
    push!.(widget, list)
    setproperty!(widget, :active, 0)
end

function updateRoomFromFields!(map::Maple.Map, room::Maple.Room, configuring::Bool=false, simple::Bool=get(Main.config, "use_simple_room_values", true))
    try
        if Main.loadedState.map != nothing
            multiplier = simple? 8 : 1

            roomName = getproperty(roomTextfield, :text, String)
            roomExists = Maple.getRoomByName(map, roomName)

            if !configuring && isa(roomExists, Maple.Room)
                return false, "A room with name '$roomName' already exists."
            end

            room.name = getproperty(roomTextfield, :text, String)

            room.size = (
                parse(Int, getproperty(widthTextfield, :text, String)) * multiplier,
                parse(Int, getproperty(heightTextfield, :text, String)) * multiplier
            )

            room.position = (
                parse(Int, getproperty(posXTextfield, :text, String)) * multiplier,
                parse(Int, getproperty(posYTextfield, :text, String)) * multiplier
            )

            # If width/height is negative we offset the room with that value
            # Then take the absolute size instead
            sizeSigns = sign.(room.size) .== -1
            room.size = abs.(room.size)
            room.position = room.position .- room.size .* sizeSigns

            minimumRecommended = (floor(Int, 320 / multiplier), floor(Int, 184 / multiplier))
            if any(room.size .< (320, 184))
                if !ask_dialog("The size you have chosen is smaller than the recommended minimum size $minimumRecommended.\nAre you sure you want this size?", roomWindow)
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

            room.disableDownTransition = getproperty(disableDownTransitionCheckBox, :active, Bool)

            # Remove all instances of checkpoints
            # Add new one if the room should have one
            checkpoint = getproperty(checkpointCheckBox, :active, Bool)
            filter!(e -> e.name != "checkpoint", room.entities)
            if checkpoint
                push!(room.entities, Maple.ChapterCheckpoint(0, 0))
            end

            room.music = Gtk.bytestring(Gtk.GAccessor.active_text(musicCombo))
            room.windPattern = get(windPatterns, getproperty(windPatternCombo, :active, Int) + 1, "None")

            if !(room.music in songList) && !startswith(room.music, "event:/")
                info_dialog("You have entered an invalid song name.\nIf you're using a custom song, make sure to copy the event path from FMOD Studio, which starts with 'event:/'")

                return false, false
            end

            return true, "OK"
        end

    catch e
        println(e)
        return false, "Some of the inputs you have made might be incorrect."
    end
end

function setFieldsFromRoom(room::Maple.Room, simple::Bool=get(Main.config, "use_simple_room_values", true))
    multiplier = simple? 8 : 1

    setproperty!(roomTextfield, :text, room.name)

    width, height = room.size
    setproperty!(widthTextfield, :text, string(round(Int, width / multiplier)))
    setproperty!(heightTextfield, :text, string(round(Int, height / multiplier)))

    x, y = room.position
    setproperty!(posXTextfield, :text, string(round(Int, x / multiplier)))
    setproperty!(posYTextfield, :text, string(round(Int, y / multiplier)))

    setproperty!(darkCheckBox, :active, room.dark)
    setproperty!(spaceCheckBox, :active, room.space)
    setproperty!(underwaterCheckBox, :active, room.underwater)
    setproperty!(whisperCheckBox, :active, room.whisper)

    setproperty!(musicLayer1CheckBox, :active, room.musicLayer1)
    setproperty!(musicLayer2CheckBox, :active, room.musicLayer2)
    setproperty!(musicLayer3CheckBox, :active, room.musicLayer3)
    setproperty!(musicLayer4CheckBox, :active, room.musicLayer4)

    hasCheckpoint = findfirst(e -> e.name == "checkpoint", room.entities)
    setproperty!(disableDownTransitionCheckBox, :active, room.disableDownTransition)
    setproperty!(checkpointCheckBox, :active, hasCheckpoint != 0)

    setproperty!(windPatternCombo, :active, findfirst(windPatterns, room.windPattern) - 1)
    setproperty!(musicCombo, :active, findfirst(songList, room.music) - 1)
end

function createRoomHandler(widget)
    room = Maple.Room()
    success, reason = updateRoomFromFields!(Main.loadedState.map, room)

    if success
        # Set the last selected values as the new "defaults" for this session
        Maple.updateTileSize!(room, Maple.tile_fg_names["Air"], Maple.tile_fg_names["Stone"])

        push!(Main.loadedState.map.rooms, room)

        Main.updateTreeView!(Main.roomList, Main.getTreeData(Main.loadedState.map), row -> row[1] == room.name)
        markForRedraw(room, Main.loadedState.map)
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

    for layer in dr.layers
        layer.redraw = true
    end
end

function updateRoomHandler(widget)
    success, reason = updateRoomFromFields!(Main.loadedState.map, Main.loadedState.room, true)

    if success
        Maple.updateTileSize!(Main.loadedState.room, Maple.tile_fg_names["Air"], Maple.tile_fg_names["Stone"])

        Main.updateTreeView!(Main.roomList, Main.getTreeData(Main.loadedState.map), row -> row[1] == Main.loadedState.room.name)
        markForRedraw(Main.loadedState.room, Main.loadedState.map)
        draw(Main.canvas)

        showRoomWindow()

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
    present(roomWindow)

    return true
end

function hideRoomWindow(widget=nothing, event=nothing)
    spawnWindowIfAbsent!()
    visible(roomWindow, false)

    return true
end

function createRoom(widget::Gtk.GtkMenuItemLeaf=MenuItem())
    if Main.loadedState.map === nothing
        info_dialog("No map is currently loaded.", Main.window)

    else
        spawnWindowIfAbsent!()

        setproperty!(roomWindow, :title, "$(Main.baseTitle) - Create Room")

        signal_handler_disconnect(roomCreationButton, roomButtonSignal)
        setproperty!(roomCreationButton, :label, "Create Room")
        global roomButtonSignal = signal_connect(createRoomHandler, roomCreationButton, "clicked")

        # Copy all fields from the selected room
        if Main.loadedState.map !== nothing && Main.loadedState.room !== nothing
            global templateRoom = deepcopy(Main.loadedState.room)
        end

        Gtk.GLib.@sigatom setFieldsFromRoom(templateRoom)

        showRoomWindow()
    end
end

function configureRoom(widget::Gtk.GtkMenuItemLeaf=MenuItem())
    if Main.loadedState.map != nothing && Main.loadedState.room != nothing
        spawnWindowIfAbsent!()

        setproperty!(roomWindow, :title, "$(Main.baseTitle) - $(Main.loadedState.room.name)")

        signal_handler_disconnect(roomCreationButton, roomButtonSignal)
        setproperty!(roomCreationButton, :label, "Update Room")
        global roomButtonSignal = signal_connect(updateRoomHandler, roomCreationButton, "clicked")

        Gtk.GLib.@sigatom setFieldsFromRoom(Main.loadedState.room)

        showRoomWindow()
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

disableDownTransitionCheckBox = CheckButton("Disable Down Transition")
checkpointCheckBox = CheckButton("Checkpoint")

musicCombo = ComboBoxText(true)
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

roomGrid[1, 6] = disableDownTransitionCheckBox
roomGrid[2, 6] = checkpointCheckBox

roomGrid[1, 7] = musicLabel
roomGrid[2, 7] = musicCombo
roomGrid[3, 7] = windPatternLabel
roomGrid[4, 7] = windPatternCombo

roomGrid[1:4, 8] = roomCreationButton

function createWindow()
    roomWindow = Window("$(Main.baseTitle) - New Room", -1, -1, false, icon = Main.windowIcon, gravity = GdkGravity.GDK_GRAVITY_CENTER
    ) |> (Frame() |> (roomBox = Box(:v)))

    # Hide window instead of destroying it
    signal_connect(hideRoomWindow, roomWindow, "delete_event")
    
    push!(roomBox, roomGrid)
    showall(roomWindow)

    return roomWindow
end

end