if !isdefined(:TEST_RUNNING)
    try
        Pkg.installed("Maple")

    catch err
        println("Maple is not installed - Please run `julia install_ahorn.jl` to install all necessary dependendies.")
        exit()
    end
end

using Gtk, Gtk.ShortNames, Gtk.GConstants
using Cairo
using Maple

macro abs(path)
    :($(normpath(joinpath(@__DIR__, path))))
end

# This makes Gtk dialogs closeable
sleep(0)

baseTitle = "Ahorn α"
iconFile = @abs "../docs/logo-256-a.png"
logoFile = @abs "../docs/logo-1024-a.png"

storageDirectory = joinpath(homedir(), ".ahorn")
configFilename = joinpath(storageDirectory, "config.json")
persistenceFilename = joinpath(storageDirectory, "persistence.json")

include("config.jl")
include("debug.jl")

config = loadConfig(configFilename)
persistence = loadConfig(persistenceFilename)

# Stop timemachine errors
sleep(0)

windowIcon = Pixbuf(filename = iconFile, width = -1, height = -1, preserve_aspect_ratio = true)
window = Window(baseTitle, 1280, 720, true, true, icon = windowIcon
) |> (Frame() |> (box = Box(:v)))

include("init_ahorn.jl")
configured = configureCelesteDir()

if !configureCelesteDir()
    error("Celeste installation not configured")
end

extractGamedata(storageDirectory, get(debug.config, "ALWAYS_FORCE_GAME_EXTRACTION", false))

loadedMap = nothing
selectedRoom = ""
loadedRoom = nothing
loadedFilename = ""

include("color_constants.jl")
include("module_loader.jl")
include("rectangle.jl")
include("line.jl")
include("camera.jl")
include("list_view_helper.jl")
include("menubar.jl")
include("celeste_render.jl")
include("menu_tiles.jl")
include("selections.jl")
include("tools.jl")
include("roomlist.jl")
include("file_dialogs.jl")
include("room_window.jl")
include("about_window.jl")
include("map_window.jl")
include("update_window.jl")
include("everest_rcon.jl")
include("hotkey.jl")
include("event_handler.jl")

camera = Camera(0, 0, defaultZoom)

canvas = Canvas(0, 0)
canvas.is_realized = true
setproperty!(canvas, :hexpand, true)
setproperty!(canvas, :vexpand, true)

@guarded draw(canvas) do widget
    if loadedMap !== nothing && isa(loadedMap, Map)
        drawMap(canvas, camera, loadedMap)
    end
end

add_events(canvas,
    GConstants.GdkEventMask.SCROLL |
    GConstants.GdkEventMask.BUTTON_PRESS |
    GConstants.GdkEventMask.BUTTON_RELEASE |
    GConstants.GdkEventMask.BUTTON1_MOTION |
    GConstants.GdkEventMask.BUTTON3_MOTION
)

# Use this for now, can't tell if map has actually changed
signal_connect((widget, event=nothing) -> !ask_dialog("You might have unsaved changes in your map.\n Please confirm that you want to exit the program.", window), window, "delete_event")

# signal_connect(resize_event, window, "resize")
signal_connect(key_press_event, window, "key-press-event")
signal_connect(key_release_event, window, "key-release-event")

signal_connect(focus_out_event, window, "focus-out-event")

signal_connect(scroll_event, canvas, "scroll-event")
signal_connect(motion_notify_event, canvas, "motion-notify-event")
signal_connect(button_press_event, canvas, "button-press-event")
signal_connect(button_release_event, canvas, "button-release-event")

hotkeys = Hotkey[
    Hotkey(
        's',
        menuFileSave,
        Function[
            modifierControl
        ]
    ),
    Hotkey(
        'S',
        showFileSaveDialog,
        Function[
            modifierControl,
            modifierShift
        ]
    ),
    Hotkey(
        'o',
        showFileOpenDialog,
        Function[
            modifierControl
        ]
    ),
    Hotkey(
        't',
        RoomWindow.createRoom,
        Function[
            modifierControl
        ]
    ),
    Hotkey(
        'T',
        RoomWindow.configureRoom,
        Function[
            modifierControl,
            modifierShift
        ]
    )
]

menubar = generateMenubar(
    ("File", "Room", "Help"),
    [
        [
            ("New", createNewMap),
            ("Open", showFileOpenDialog),
            ("Save", menuFileSave),
            ("Save as", showFileSaveDialog),
            ("Exit", w -> destroy(window))
        ],
        [
            ("Add", RoomWindow.createRoom),
            ("Configure", RoomWindow.configureRoom),
        ],
        [
            ("About", AboutWindow.showAboutWindow),
            ("Update", UpdateWindow.updateAhorn)
        ]
    ]
)

grid = Grid()

scrollableWindowRoomList = ScrolledWindow(vexpand=true, hscrollbar_policy=Gtk.GtkPolicyType.NEVER)
push!(scrollableWindowRoomList, roomList.tree)

scrollableWindowMaterialList = ScrolledWindow(vexpand=true, hscrollbar_policy=Gtk.GtkPolicyType.NEVER)
push!(scrollableWindowMaterialList, materialList.tree)

grid[1:6, 1] = menubar
grid[1, 2] = scrollableWindowRoomList
grid[2, 2] = canvas
grid[3, 2] = toolList.tree
grid[4, 2] = layersList.tree
grid[5, 2] = subtoolList.tree
grid[6, 2] = scrollableWindowMaterialList

push!(box, grid)

showall(window)
maximize(window)

# Select first room
select!(roomList)

include("interactive_workaround.jl")