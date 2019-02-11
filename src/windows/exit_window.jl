module ExitWindow

using Gtk, Gtk.ShortNames
using ..Ahorn

function exitAhorn(widget=nothing, event=nothing)
    dialogText = "You might have unsaved changes in your map.\nPlease confirm that you want to exit the program."
    res = Ahorn.loadedState.lastSavedHash == hash(Ahorn.loadedState.side) || ask_dialog(dialogText, Ahorn.window)

    # For detecting unpredicted shutdowns
    Ahorn.persistence["currently_running"] = false

    Ahorn.saveConfig(Ahorn.config, true)
    Ahorn.saveConfig(Ahorn.persistence, true)

    # If called via Exit button instead of "X" on window
    if isa(widget, Ahorn.MenuItemsTypes) && res
        destroy(Ahorn.window)
    end

    return !res
end

end