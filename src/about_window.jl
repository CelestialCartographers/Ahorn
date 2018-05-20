module AboutWindow

using Gtk, Gtk.ShortNames, Gtk.GConstants

window = nothing

function spawnWindowIfAbsent!()
    if window === nothing
        icon = Pixbuf(filename = Main.logoFile, width = 256, height = 256, preserve_aspect_ratio = true)
        version = "Alpha - Very Broken - "
        try
            version *= "Git Commit " * string(LibGit2.GitHash(LibGit2.head(LibGit2.GitRepo(Main.@abs "../"))))[1:7]
        catch e
            version *= "Don't expect a version number"
        end
        global window = AboutDialog(title = "About $(Main.baseTitle)",
        icon = Main.windowIcon, logo = icon,
        program_name = Main.baseTitle,
        comments="Level Editor for the Game Celeste\n\nPowered by Julia and Maple",
        version = version,
        website = "https://github.com/CelestialCartographers/Ahorn",
        website_label = "GitHub  Repository")
        
        # Hide window instead of destroying it
        signal_connect(hideAboutWindow, window, "delete_event")
        signal_connect(hideAboutWindow, window, "response")
        
        GAccessor.transient_for(window, Main.window)
        GAccessor.authors(window, ["Cruor", "Vexatos"])
        GAccessor.artists(window, ["Vexatos"])
    end
end

function hideAboutWindow(widget=nothing, event=nothing)
    if event == GtkResponseType.GTK_RESPONSE_DELETE_EVENT || isa(event, Gtk.GdkEvent)
        spawnWindowIfAbsent!()
        visible(window, false)
        return true
    end
end

function showAboutWindow(widget) 
    spawnWindowIfAbsent!()
    visible(window, true)
    return true
end

end