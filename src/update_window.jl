module UpdateWindow

using Gtk, Gtk.ShortNames

function do_ask_dialog(text::String; no::String="Cancel", yes::String="Update")
    if ask_dialog(text, no, yes, Main.window)
        Pkg.update("Maple")
        Pkg.update("Ahorn")
        exit()
    end
end

function clean!(repo::LibGit2.GitRepo, name::String)
    if LibGit2.isdirty(repo)
        if ask_dialog("""Your installation of $name contains changes not found on GitHub - Updating automatically is not possible.
            Would you like to revert the repository back to the state of your installed version?
            Any changes done inside the $name installtion directory may be lost.""",
            "Cancel", "Revert Repository", Main.window)
            LibGit2.reset!(repo, LibGit2.GitHash(LibGit2.head(repo)), LibGit2.Consts.RESET_HARD)
        else
            return false
        end
    end
    return true
end

function updateAhorn(widget::Gtk.GtkMenuItemLeaf=MenuItem())
    try
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