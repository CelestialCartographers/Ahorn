module UpdateWindow

using Gtk, Gtk.ShortNames
using ..Ahorn

function do_ask_dialog(text::String; no::String="Cancel", yes::String="Update")
    if ask_dialog(text, no, yes, Ahorn.window)
        Pkg.update("Maple")
        Pkg.update("Ahorn")
        # Did you know that Pkg2 resolves the REQUIRE file before updating, and not after?
        Pkg.update("Maple")
        Pkg.update("Ahorn")
        exit()
    end
end

function clean!(repo::LibGit2.GitRepo, name::String)
    if LibGit2.isdirty(repo)
        if ask_dialog("""Your installation of $name contains changes not found on GitHub - Updating automatically is not possible.
            Would you like to revert the repository back to the state of your installed version?
            Any changes done inside the $name installation directory may be lost.""",
            "Cancel", "Revert Repository", Ahorn.window)
            LibGit2.reset!(repo, LibGit2.GitHash(LibGit2.head(repo)), LibGit2.Consts.RESET_HARD)
        else
            return false
        end
    end
    return true
end

# I couldn't think of anything better
function canUpdate() 
    try
        for line in readlines(download("https://raw.githubusercontent.com/CelestialCartographers/Ahorn/master/REQUIRE"))
            m = match(r"^julia (\d+\.\d+)$", line)
            if m !== nothing
                return VersionNumber(m[1]) <= v"0.6"
            end
        end
        return false
    catch
        return false
    end
end

function updateAhorn(widget::Gtk.GtkMenuItemLeaf=MenuItem())
    try
        if !canUpdate()
            if get(Ahorn.persistence, "1_0_update_nag", true) && ask_dialog("This is the final version before Ahorn is ported to Julia 1.0.\nSoon, this updater will stop working, but it will still be telling you that an update is ready.\nWhen that happens, you will have to reinstall Ahorn from scratch, using Julia 1.0.\nCheck Discord (found in the README) for information and help.", "Okay", "Don't tell me again", Ahorn.window)
                Ahorn.persistence["1_0_update_nag"] = false
            end
        end
        repo = LibGit2.GitRepo(Pkg.dir("Ahorn"))
        LibGit2.fetch(repo)
        l, r = LibGit2.revcount(repo, "master", "origin/master")
        lc = string(LibGit2.GitHash(LibGit2.GitObject(repo, "master")))[1:7]
        rc = string(LibGit2.GitHash(LibGit2.GitObject(repo, "origin/master")))[1:7]
        if !clean!(repo, "Ahorn") || !clean!(LibGit2.GitRepo(Pkg.dir("Maple")), "Maple")
            return
        end
        if l < r
            do_ask_dialog("A new version is available! ($lc -> $rc)\nDo you wish to update Ahorn?\nThis will close the program afterwards and you will have to rerun it.")
        else
            do_ask_dialog("Ahorn is up-to-date at commit $lc.\nDo you wish to try updating anyway?\nThis will close the program afterwards and you will have to rerun it.", yes="Try Updating Anyway")
        end
    catch e
        do_ask_dialog("Do you wish to update Ahorn?\nThis will close the program afterwards and you will have to rerun it.")
    end
end

end