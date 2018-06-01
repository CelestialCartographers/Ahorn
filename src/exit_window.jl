module ExitWindow

using Gtk, Gtk.ShortNames

function exitAhorn(widget=nothing, event=nothing)
    res = ask_dialog("You might have unsaved changes in your map.\nPlease confirm that you want to exit the program.", Main.window)

    Main.saveConfig(Main.config, true)
    Main.saveConfig(Main.persistence, true)

    # If called via Exit button instead of "X" on window
    if isa(widget, Gtk.GtkMenuItemLeaf)
        destroy(Main.window)
    end

    return !res
end

end