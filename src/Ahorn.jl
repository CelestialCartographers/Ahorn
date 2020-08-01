__precompile__(false)
module Ahorn

# Fixes theme issues on Windows
if Sys.iswindows()
    ENV["GTK_THEME"] = get(ENV, "GTK_THEME", "win32")
    ENV["GTK_CSD"] = get(ENV, "GTK_CSD", "0")
end

using Gtk, Gtk.ShortNames, Gtk.GConstants
using Cairo
using Maple
using Random

function abspath(path::String)
    return normpath(joinpath(@__DIR__, path))
end

macro abs_str(path)
    abspath(path)
end

include("helpers/gtk_helpers.jl")

# Force all widgets to be Left to Right
# Program is not really useable in Right to Left mode, which Gtk respects on RTL languages for some reason
setDefaultDirection(1)

const baseTitle = "Ahorn"
const iconFile = abs"../docs/logo-256.png"
const logoFile = abs"../docs/logo-1024.png"

const windowIcon = Pixbuf(filename=iconFile, width=-1, height=-1, preserve_aspect_ratio=true)

const canvas = Canvas(0, 0)

storageDirectory = ""
configFilename = ""
persistenceFilename = ""

config = Dict{String, Any}()
persistence = Dict{String, Any}()

langdata = nothing

include("config.jl")
include("debug.jl")

include("loaded_state.jl")
include("camera.jl")

loadedState = LoadedState("", "")
camera = Camera(0, 0, 4)

# Time Machine workaround
sleep(0)

include("helpers/helpers.jl")
include("helpers/macros.jl")
include("helpers/config_helper.jl")
include("lang.jl")
include("validation_entry.jl")
include("mods.jl")
include("hotkey.jl")
include("cursor.jl")
include("multi_range.jl")
include("color_constants.jl")
include("module_loader.jl")
include("shapes/rectangle.jl")
include("shapes/simple_curve.jl")
include("shapes/line.jl")
include("shapes/circle.jl")
include("shapes/ellipse.jl")
include("helpers/list_view_helper.jl")
include("helpers/ahorn_list_helper.jl")
include("helpers/color_helper.jl")
include("helpers/xna_colors.jl")
include("helpers/form_helper.jl")
include("helpers/processing_helper.jl")
include("helpers/entity_id_helper.jl")
include("windows/settings_window.jl")
include("windows/test_eval_window.jl")
include("materials_filter.jl")
include("helpers/menubar_helper.jl")
include("celeste_render.jl")
include("effects.jl")
include("windows/map_image_dumper_window.jl")
include("windows/sprite_dumper_window.jl")
include("selections.jl")
include("property_menu.jl")
include("event_handler.jl")
include("pre_save_sanitizers.jl")
include("windows/file_dialog_window.jl")
include("windows/room_window.jl")
include("windows/about_window.jl")
include("windows/map_window.jl")
include("windows/styleground_window.jl")
include("windows/metadata_window.jl")
include("windows/update_window.jl")
include("windows/exit_window.jl")
include("history_manager.jl")
include("roomlist.jl")
include("everest_rcon.jl")
include("hotkeys.jl")
include("tools.jl")
include("menubar.jl")
include("backups.jl")
include("file_watcher.jl")
include("loading_spinner.jl")
include("object_tile_names.jl")
include("favorites.jl")

# Time Machine workaround
sleep(0)

include("windows/main_window.jl")
include("interactive_workaround.jl")

include("init_ahorn.jl")
include("init_external_modules.jl")
include("init_signals.jl")
include("init_globals.jl")

include("display_main_window.jl")

end
