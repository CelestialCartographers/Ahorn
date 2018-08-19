__precompile__(false)
module Ahorn

using Gtk, Gtk.ShortNames, Gtk.GConstants
using Cairo
using Maple

macro abs_str(path)
    :($(normpath(joinpath(@__DIR__, path))))
end

baseTitle = "Ahorn α"
iconFile = abs"../docs/logo-256-a.png"
logoFile = abs"../docs/logo-1024-a.png"

windowIcon = Pixbuf(filename=iconFile, width=-1, height=-1, preserve_aspect_ratio=true)
box = Box(:v)

canvas = Canvas(0, 0)
window = nothing

saveDialog = isdefined(Gtk, :save_dialog_native) && Gtk.libgtk_version >= v"3.20.0"? Gtk.save_dialog_native : Gtk.save_dialog
openDialog = isdefined(Gtk, :open_dialog_native) && Gtk.libgtk_version >= v"3.20.0"? Gtk.open_dialog_native : Gtk.open_dialog

storageDirectory = ""
configFilename = ""
persistenceFilename = ""

config = Dict{String, Any}()
persistence = Dict{String, Any}()

include("config.jl")
include("debug.jl")

include("loaded_state.jl")
include("camera.jl")

loadedState = LoadedState("", "")
camera = Camera(0, 0, 4)

# Time Machine workaround
sleep(0)

include("helpers.jl")
include("validation_entry.jl")
include("mods.jl")
include("color_constants.jl")
include("module_loader.jl")
include("rectangle.jl")
include("line.jl")
include("list_view_helper.jl")
include("ahorn_list_helper.jl")
include("config_window.jl")
include("materials_filter.jl")
include("menubar_helper.jl")
include("celeste_render.jl")
include("map_image_dumper.jl")
include("selections.jl")
include("property_menu.jl")
include("event_handler.jl")
include("file_dialogs.jl")
include("room_window.jl")
include("about_window.jl")
include("map_window.jl")
include("styleground_window.jl")
include("metadata_window.jl")
include("update_window.jl")
include("exit_window.jl")
include("history_manager.jl")
include("roomlist.jl")
include("everest_rcon.jl")
include("hotkeys.jl")
include("tools.jl")
include("menubar.jl")

# Time Machine workaround
sleep(0)

include("main_window.jl")
include("interactive_workaround.jl")

include("init_ahorn.jl")
include("init_external_modules.jl")
include("init_signals.jl")
include("init_globals.jl")

include("display_main_window.jl")

end
