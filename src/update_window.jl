module UpdateWindow

using Gtk, Gtk.ShortNames

function do_ask_dialog(text::String)
    if ask_dialog(text, "Cancel", "Update", Main.window)
        Pkg.update("Maple")
        Pkg.update("Ahorn")
        exit()
    end
end

function updateAhorn(widget::Gtk.GtkMenuItemLeaf=MenuItem())
    try
        repo = LibGit2.GitRepo(Main.@abs "../")
        LibGit2.fetch(repo)
        l, r = LibGit2.revcount(repo, "master", "origin/master")
        lc = string(LibGit2.GitHash(LibGit2.GitObject(repo, "master")))[1:7]
        rc = string(LibGit2.GitHash(LibGit2.GitObject(repo, "origin/master")))[1:7]
        if l < r
            do_ask_dialog("A new version is available! ($lc -> $rc)\nDo you wish to update Ahorn?\nThis will close the program afterwards and you will have to rerun it.")
        else
            info_dialog("Ahorn is up-to-date at commit $lc.", Main.window)
        end
    catch e
        println(e)
        do_ask_dialog("Do you wish to update Ahorn?\nThis will close the program afterwards and you will have to rerun it.")
    end
end

end