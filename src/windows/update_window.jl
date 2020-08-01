module UpdateWindow

using Gtk, Gtk.ShortNames, Pkg
using ..Ahorn

function do_ask_dialog(text::String; no::String="Cancel", yes::String="Update")
    if ask_dialog(text, no, yes, Ahorn.window)
        info_dialog("Ahorn will now be updated.\nThis will freeze the window during the process.\nDo not close Ahorn, you will get notified when the update completes.", Ahorn.window)
        Pkg.update(["Maple", "Ahorn"])
        if ask_dialog("Ahorn updated!\nBut the old version of Ahorn still lingers around.\nWe can run gc for you to clean up installed package versions,\nbut that is going to affect all your julia environments.\nIf you do not have any other Julia packages installed,\nthis should be safe to do and save you some disk space.", Ahorn.window)
            Pkg.gc()
        end
        exit()
    end
end

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

pkgpath(pkg) = pathof(pkg) |> dirname |> dirname

function pkghash()
    try
        local ctx = Pkg.Types.Context()
        local pkg = PackageSpec(name="Ahorn", uuid=ctx.env.project.deps["Ahorn"])
        Pkg.Operations.resolve_versions!(ctx, [pkg])
        return string(pkg.repo.tree_sha)[1:7]
    catch e
        return nothing
    end
end

function updateAhorn(widget::Union{Ahorn.MenuItemsTypes, Nothing}=nothing)
    ask_dialog("""Would you like to check for updates?
            This will download files required for the update if there is one.
            The window might also freeze for a bit.
            Make sure not to close Ahorn during this!""",
            "Cancel", "Check for Updates", Ahorn.window) || return
    try
        sim = take_stdout() do
            # Simulate an update. This is still going to download the repo.
            Pkg.update(["Maple", "Ahorn"], preview=true)
        end
        
        if occursin(r"(Ahorn|Maple)[^\n]+⇒", sim) || occursin(r"~ (Ahorn|Maple)", sim)
            do_ask_dialog("A new version is available!\nDo you wish to update Ahorn?\nThis will close the program afterwards and you will have to rerun it.")
        else
            h = pkghash()
            do_ask_dialog("Ahorn seems to be up-to-date$(h !== nothing ? " at hash $h" : "").\nDo you wish to try updating anyway?\nThis will close the program afterwards and you will have to rerun it.", yes="Try Updating Anyway")
        end
    catch e
        do_ask_dialog("The update check failed for some reason.\nDo you wish to update Ahorn anyway?\nThis will close the program afterwards and you will have to rerun it.")
        println(Base.stderr, "Update check failed")
        for (exc, bt) in Base.catch_stack()
            showerror(Base.stderr, exc, bt)
            println()
        end
    end
end

end
