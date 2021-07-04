module UpdateWindow

using Gtk, Gtk.ShortNames, Pkg
using ..Ahorn
using Ahorn.PackageHelper

# Modified from stream.jl
function take_stdout(f::Function)
    local oldout = Base.stdout
    local (rd, wr) = redirect_stdout()
    f()
    redirect_stdout(oldout)
    close(wr)
    local res = readavailable(rd)
    close(rd)
    return String(res)
end

function ask_gc_and_exit()
    if ask_dialog("""Ahorn updated!
            But the old version of Ahorn still lingers around.
            We can run gc for you to clean up installed package versions,
            but that is going to affect all your julia environments.
            If you do not have any other Julia packages installed,
            this should be safe to do and save you some disk space.""",
        "Skip", "Run gc", Ahorn.window)
        Pkg.gc()
    end
    info_dialog("""Ahorn will now close.
                Start it again to use the updated version.""",
                Ahorn.window)
    exit()
end

function do_ask_dialog(text::String; no::String="Cancel", yes::String="Update")
    if ask_dialog(text, no, yes, Ahorn.window)
        info_dialog("""Ahorn will now be updated.
            This will freeze the window during the process.
            Do not close Ahorn, you will get notified when the update completes.""", Ahorn.window)

        Pkg.update(["Maple", "Ahorn"])

        ask_gc_and_exit()
    end
end

function updateAhorn(widget::Union{Ahorn.MenuItemsTypes, Nothing}=nothing)
    ask_dialog("Would you like to check for updates?",
            "Cancel", "Check for Updates", Ahorn.window) || return
    try
        localhash = pkghash()
        remotehash = nothing
        if pkghash !== nothing
            remotehash = latesthash()
        else
            localhash = pkghash_tree()
            if pkghash !== nothing
                remotehash = latesthash_tree()
            end
        end

        if localhash === nothing || remotehash === nothing
            updateAhorn_fallback()
            return
        end

        if localhash != remotehash
            do_ask_dialog("""A new version is available!
                    Do you wish to update Ahorn?
                    This will close the program afterwards and you will have to rerun it.""")
        else
            h = pkghash_short()
            do_ask_dialog("""Ahorn seems to be up-to-date$(h !== nothing ? " at hash $h" : "").
                    Do you wish to try updating anyway?
                    This will close the program afterwards and you will have to rerun it.""",
                    yes="Try Updating Anyway")
        end
    catch e
        updateAhorn_fallback()
        return
    end
end

function updateAhorn_fallback()
    ask_dialog("""The update check failed for some reason.
            Do you wish to try updating Ahorn anyway?
            This will download files required for the update if there is one.
            The window might also freeze for a bit.
            Make sure not to close Ahorn during the process!""",
            "Cancel", "Update", Ahorn.window) || return
    try
        info_dialog("""Ahorn will now be updated.
            This will freeze the window during the process.
            Do not close Ahorn, you will get notified when the update completes.""",
            Ahorn.window)
        sim = take_stdout() do
            Pkg.update(["Maple", "Ahorn"])
        end

        println(Base.stdout, sim)

        if occursin(r"(Ahorn|Maple)[^\n]+⇒", sim) || occursin(r"~ (Ahorn|Maple)", sim)
            ask_gc_and_exit()
        else
            h = pkghash_short()
            info_dialog("""Ahorn seems to be up-to-date$(h !== nothing ? " at hash $h" : "").
                    No new update was found.""",
                    Ahorn.window)
        end
    catch e
        println(Base.stderr, "Update check failed")
        for (exc, bt) in Base.catch_stack()
            showerror(Base.stderr, exc, bt)
            println(Base.stderr, "")
        end
        info_dialog("""Something went wrong during the update.
                Please check your error.log file in the Ahorn config directory.""",
                Ahorn.window)
    end
end

end
