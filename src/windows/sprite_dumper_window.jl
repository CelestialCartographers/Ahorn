module SpriteDumperWindow

using Maple, Cairo
using Gtk, Gtk.ShortNames
using ..Ahorn

# This will not dump original sprites if any of those are overwritten
function dumpSpritesDialog(w)
    celesteDir = get(Ahorn.config, "celeste_dir", "")
    targetDir = ispath(celesteDir) ? celesteDir : pwd()
    
    outdir = Ahorn.saveDialog("Save as", Ahorn.window, action=GtkFileChooserAction.SELECT_FOLDER, folder=targetDir)
    useRealSize = get(Ahorn.debug.config, "SPRITE_DUMPER_REAL_SIZE", true)

    if outdir != ""
        for (atlas, sprites) in Ahorn.atlases            
            for (name, spriteHolder) in sprites
                sprite = spriteHolder.sprite

                if sprite.width == 0 && sprite.height == 0
                    continue
                end
                
                filename = joinpath(outdir, atlas, name) * ".png"

                width = useRealSize ? sprite.realWidth : sprite.width
                height = useRealSize ? sprite.realHeight : sprite.height

                offsetX = useRealSize ? -sprite.offsetX : 0
                offsetY = useRealSize ? -sprite.offsetY : 0

                surface = Cairo.CairoARGBSurface(width, height)
                ctx = Ahorn.getSurfaceContext(surface)

                Ahorn.drawImage(ctx, sprite, offsetX, offsetY, alpha=1.0)

                mkpath(dirname(filename))
                open(io -> Cairo.write_to_png(surface, io), filename, "w")

                deleteSurface(surface)
            end
        end
    end

    Ahorn.info_dialog("Done dumping sprites.", Ahorn.window)
end

end