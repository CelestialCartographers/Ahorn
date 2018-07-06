module ExitWindow

using Gtk, Gtk.ShortNames

function exitAhorn(widget=nothing, event=nothing)
    dialogText = "You might have unsaved changes in your map.\nPlease confirm that you want to exit the program."
    res = isequal(Main.loadedState.lastSavedMap, Main.loadedState.map) || ask_dialog(dialogText, Main.window)

    Main.saveConfig(Main.config, true)
    Main.saveConfig(Main.persistence, true)

    # If called via Exit button instead of "X" on window
    if isa(widget, Gtk.GtkMenuItemLeaf) && res
        destroy(Main.window)
    end

    return !res
end

end