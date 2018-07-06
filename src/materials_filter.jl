materialFilterEntry = Entry()

@guarded signal_connect(materialFilterEntry, "changed") do widget
    text = getproperty(materialFilterEntry, :text, String)

    for row in 1:length(materialList.data)
        materialList.visible[row] = contains(lowercase(materialList.data[row][1]), lowercase(text))
    end

    Gtk.GLib.@sigatom filterContainer!(materialList)
end


function focusFilterEntry!(args...)
    GAccessor.focus(window, materialFilterEntry)
end