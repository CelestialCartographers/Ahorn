module AboutWindow

using Gtk, Gtk.ShortNames, Gtk.GConstants, Pkg
using ..Ahorn

window = nothing

function spawnWindowIfAbsent!()
    if window === nothing
        icon = Pixbuf(filename = Ahorn.logoFile, width = 256, height = 256, preserve_aspect_ratio = true)
        version = ""
        try
            local ctx = Pkg.Types.Context()
            version *= "Hash " * string(ctx.env.manifest[ctx.env.project.deps["Ahorn"]].tree_hash)[1:7]
        catch e
            version *= "Don't expect a version number"
        end
        global window = AboutDialog(title = "About $(Ahorn.baseTitle)",
        icon = Ahorn.windowIcon, logo = icon,
        program_name = Ahorn.baseTitle,
        comments="Level Editor for the Game Celeste\n\nPowered by Julia and Maple",
        version = version,
        website = "https://github.com/CelestialCartographers/Ahorn",
        website_label = "GitHub  Repository")
        
        # Hide window instead of destroying it
        signal_connect(hideAboutWindow, window, "delete_event")
        signal_connect(hideAboutWindow, window, "response")
        
        GAccessor.transient_for(window, Ahorn.window)
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