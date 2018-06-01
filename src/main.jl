if !isdefined(:TEST_RUNNING)
    try
        Pkg.installed("Maple")

    catch err
        println("Maple is not installed - Please run `julia install_ahorn.jl` to install all necessary dependencies.")
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
window = Window(baseTitle, 1280, 720, true, true, icon = windowIcon, gravity = GdkGravity.GDK_GRAVITY_CENTER
) |> (Frame() |> (box = Box(:v)))

include("init_ahorn.jl")
configured = configureCelesteDir()

if !configureCelesteDir()
    error("Celeste installation not configured")
end

extractGamedata(storageDirectory, get(debug.config, "ALWAYS_FORCE_GAME_EXTRACTION", false))

include("loaded_state.jl")
include("camera.jl")

camera = Camera(0, 0, defaultZoom)
loadedState = LoadedState(get(Main.persistence, "files_lastroom", ""), get(Main.persistence, "files_lastfile", ""))

include("color_constants.jl")
include("module_loader.jl")
include("rectangle.jl")
include("line.jl")
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
include("styleground_window.jl")
include("update_window.jl")
include("exit_window.jl")
include("everest_rcon.jl")
include("hotkey.jl")
include("event_handler.jl")

sleep(0)

canvas = Canvas(0, 0)
canvas.is_realized = true
setproperty!(canvas, :hexpand, true)
setproperty!(canvas, :vexpand, true)

@guarded draw(canvas) do widget
    if loadedState.map !== nothing && isa(loadedState.map, Map)
        drawMap(canvas, camera, loadedState.map)
    end
end

add_events(canvas,
    GConstants.GdkEventMask.SCROLL |
    GConstants.GdkEventMask.BUTTON_PRESS |
    GConstants.GdkEventMask.BUTTON_RELEASE |
    GConstants.GdkEventMask.BUTTON1_MOTION |
    GConstants.GdkEventMask.BUTTON3_MOTION
)

signal_connect(ExitWindow.exitAhorn, window, "delete_event")
signal_connect(
    function(window::Gtk.GtkWindowLeaf, event::Gtk.GdkEventAny)
        persistence["start_maximized"] = getproperty(window, :is_maximized, Bool)
    end,
    window,
    "window-state-event"
)

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
    ("File", "Map", "Room", "Help"),
    [
        [
            ("New", createNewMap),
            ("Open", showFileOpenDialog),
            ("Save", menuFileSave),
            ("Save as", showFileSaveDialog),
            ("Exit", ExitWindow.exitAhorn),
        ],
        [
            ("Stylegrounds", StylegroundWindow.editStylegrounds),
        ],
        [
            ("Add", RoomWindow.createRoom),
            ("Configure", RoomWindow.configureRoom),
        ],
        [
            ("Check for Updates", UpdateWindow.updateAhorn),
            ("About", AboutWindow.showAboutWindow),
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

# If the window was previously maximized, maximize again
if get(persistence, "start_maximized", false)
    maximize(window)
end

# Select the specified room or the first one
if loadedState.room !== nothing
    select!(roomList, r -> r[1] == loadedState.roomName)
    setCamera!(camera, loadedState.room.position...)

else
    select!(roomList)
end

include("interactive_workaround.jl")