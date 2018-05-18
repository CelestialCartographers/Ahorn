module UpdateWindow

using Gtk, Gtk.ShortNames

function updateAhorn(widget::Gtk.GtkMenuItemLeaf=MenuItem())
    if ask_dialog("Do you wish to update Ahorn?\nThis will close the program afterwards and you will have to rerun it.", Main.window)
        Pkg.update("Ahorn")
        exit()
    end
end

end