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

macro abs_str(path)
    :($(normpath(joinpath(@__DIR__, path))))
end

saveDialog = isdefined(Gtk, :save_dialog_native) && Gtk.libgtk_version >= v"3.20.0"? Gtk.save_dialog_native : Gtk.save_dialog
openDialog = isdefined(Gtk, :open_dialog_native) && Gtk.libgtk_version >= v"3.20.0"? Gtk.open_dialog_native : Gtk.open_dialog

# This makes Gtk dialogs closeable
sleep(0)

baseTitle = "Ahorn α"
iconFile = abs"../docs/logo-256-a.png"
logoFile = abs"../docs/logo-1024-a.png"

storageDirectory = joinpath(homedir(), ".ahorn")
configFilename = joinpath(storageDirectory, "config.json")
persistenceFilename = joinpath(storageDirectory, "persistence.json")

include("config.jl")
include("debug.jl")

config = loadConfig(configFilename, 0)
persistence = loadConfig(persistenceFilename, 90)

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

loadedState = LoadedState(
    get(Main.persistence, "files_lastroom", ""),
    get(Main.persistence, "files_lastfile", "")
)
camera = Camera(
    get(persistence, "camera_position_x", 0),
    get(persistence, "camera_position_y", 0),
    get(persistence, "camera_scale", get(config, "camera_default_zoom", 4))
)

include("mods.jl")
include("color_constants.jl")
include("module_loader.jl")
include("rectangle.jl")
include("line.jl")
include("list_view_helper.jl")
include("menubar.jl")
include("celeste_render.jl")
#include("menu_tiles.jl")
include("map_image_dumper.jl")
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

        persistence["camera_position_x"] = camera.x
        persistence["camera_position_y"] = camera.y
        persistence["camera_scale"] = camera.scale
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

        return false
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

# Handle menubars better in the feature
# Allow registering of custom menubar items, like debug menu
menubarHeaders = ["File", "Map", "Room", "Help"]
menubarItems = [
    [
        ("New", createNewMap),
        ("Open", showFileOpenDialog),
        ("Save", menuFileSave),
        ("Save as", showFileSaveDialog),
        ("Exit", ExitWindow.exitAhorn),
    ],
    [
        ("Stylegrounds", StylegroundWindow.editStylegrounds),
        ("Save Map Image", MapImageDumper.dumpMapImageDialog)
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

if get(debug.config, "DEBUG_MENU_DROPDOWN", false)
    push!(menubarHeaders, "Debug")
    push!(menubarItems, [
        ("Reload Tools", (w) -> debug.reloadTools!()),
        ("Reload Entities", (w) -> debug.reloadEntities!()),
        ("Reload Triggers", (w) -> debug.reloadTriggers!()),
        ("Reload External Sprites", (w) -> loadExternalSprites!()),
        ("Redraw All Rooms", (w) -> debug.redrawAllRooms!())
    ])
end

menubar = Menubar.generateMenubar(menubarHeaders, menubarItems)

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

else
    select!(roomList)
end

include("interactive_workaround.jl")