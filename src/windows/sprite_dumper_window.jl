module SpriteDumperWindow

using Maple, Cairo
using Gtk, Gtk.ShortNames
using ..Ahorn

# This will not dump original sprites if any of those are overwritten
function dumpSpritesDialog(w)
    celesteDir = get(Ahorn.config, "celeste_dir", "")
    targetDir = ispath(celesteDir) ? celesteDir : pwd()
    
    outdir = Ahorn.saveDialog("Save as", Ahorn.window, action=GtkFileChooserAction.SELECT_FOLDER, folder=targetDir)

    if outdir != ""
        for (atlas, sprites) in Ahorn.atlases
            for (name, spriteHolder) in sprites
                sprite = spriteHolder.sprite

                if sprite.width == 0 && sprite.height == 0
                    continue
                end
                
                filename = joinpath(outdir, atlas, name) * ".png"

                surface = Cairo.CairoARGBSurface(sprite.width, sprite.height)
                ctx = Cairo.getSurfaceContext(surface)

                Ahorn.drawImage(ctx, sprite, 0, 0, alpha=1.0)

                mkpath(dirname(filename))
                open(io -> Cairo.write_to_png(surface, io), filename, "w")

                Cairo.destroy(surface)
            end
        end
    end

    Ahorn.info_dialog("Done dumping sprites.", Ahorn.window)
end

end