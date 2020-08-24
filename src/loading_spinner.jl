module LoadingSpinner

using ..Ahorn
using Gtk, Gtk.ShortNames
using Cairo

animationPreviousTime = 0
animationDelay = 5

const baseWidth = ceil(Int, width(Ahorn.Assets.crowIdle))
const baseHeight = ceil(Int, height(Ahorn.Assets.crowIdle))

const startFrame = Ahorn.scalePixbufSimple(Ahorn.pixbufFromSurface(Ahorn.Assets.crowIdle), baseWidth * 4, baseHeight * 4)
const idleFrame = Ahorn.scalePixbufSimple(Ahorn.pixbufFromSurface(Ahorn.Assets.crowIdle), baseWidth * 4, baseHeight * 4)
const peck1Frame = Ahorn.scalePixbufSimple(Ahorn.pixbufFromSurface(Ahorn.Assets.crowPeck1), baseWidth * 4, baseHeight * 4)
const peck2Frame = Ahorn.scalePixbufSimple(Ahorn.pixbufFromSurface(Ahorn.Assets.crowPeck2), baseWidth * 4, baseHeight * 4)

# Peck twice, return to idle position
const frames = Tuple{Gtk.Pixbuf, Number}[
    (peck1Frame, 0.08),
    (peck2Frame, 0.08),
    (idleFrame, 0.08),
    (peck1Frame, 0.08),
    (peck2Frame, 0.08),
    (idleFrame, 0.08),
]

function animate(dlg::Gtk.GObject)
    global animationPreviousTime

    if time() > animationPreviousTime + animationDelay
        for (frame, delay) in frames
            Ahorn.setProgressDialogPixbuf!(dlg, frame)
            sleep(delay)
        end

        animationPreviousTime = time()

        return true
    end

    return false
end

end