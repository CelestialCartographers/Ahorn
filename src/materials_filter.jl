materialFilterEntry = Entry(
    primary_icon_name="edit-find-symbolic",
    secondary_icon_name="edit-clear-symbolic",
    placeholder_text="Search..."
)

@guarded signal_connect(materialFilterEntry, "changed") do widget
    text = getproperty(widget, :text, String)

    for row in 1:length(materialList.data)
        materialList.visible[row] = contains(lowercase(materialList.data[row][1]), lowercase(text))
    end

    Gtk.GLib.@sigatom filterContainer!(materialList)
end

@guarded signal_connect(materialFilterEntry, "icon-press") do widget, n, event
    Gtk.GLib.@sigatom setproperty!(widget, :text, "")
end

function focusFilterEntry!(args...)
    GAccessor.focus(window, materialFilterEntry)
end