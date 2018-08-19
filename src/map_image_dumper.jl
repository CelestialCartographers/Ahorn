module MapImageDumper

using Maple, Cairo
using Gtk, Gtk.ShortNames
using ..Ahorn

function bounds(m::Maple.Map)
    tlx = tly = typemax(Int)
    brx = bry = typemin(Int)

    for room in m.rooms
        x, y = Int.(room.position)
        w, h = Int.(room.size)

        tlx = min(tlx, x)
        tly = min(tly, y)

        brx = max(brx, x + w)
        bry = max(bry, y + h)
    end

    return tlx, tly, brx, bry
end

surfaceSize(tlx::Number, tly::Number, brx::Number, bry::Number) = brx - tlx, bry - tly
surfaceSize(m::Maple.Map) = surfaceSize(bounds(m)...)

function drawMapSurface(m::Maple.Map)
    dummyMap = deepcopy(m)

    tlx, tly, brx, bry = bounds(dummyMap)
    width, height = surfaceSize(tlx, tly, brx, bry)

    camera = Ahorn.Camera(tlx, tly, 1)
    surface = Cairo.CairoARGBSurface(width, height)
    ctx = Cairo.creategc(surface)

    Ahorn.paintSurface(ctx, (1.0, 1.0, 1.0, 0.0))
    pattern_set_filter(get_source(ctx), Cairo.FILTER_NEAREST)

    for room in dummyMap.rooms
        dr = Ahorn.getDrawableRoom(dummyMap, room)
        dr.fillColor = (1.0, 1.0, 1.0, 0.0)

        Ahorn.getLayerByName(dr.layers, "triggers").visible = false
        Ahorn.getLayerByName(dr.layers, "tools").visible = false

        alpha = 1.0
        Ahorn.drawRoom(ctx, camera, dr, alpha=alpha)
    end

    # Destroy the dummy renders
    rooms = Ahorn.getDrawableRooms(dummyMap)
    Ahorn.destroy.(rooms)

    return surface
end

function dumpMapImageDialog(w)
    celesteDir = get(Ahorn.config, "celeste_dir", "")
    
    filename = ""
    cd(celesteDir) do
        filename = Ahorn.saveDialog("Save as", Ahorn.window, ["*.png"])
    end

    if filename != ""
        map = Ahorn.loadedState.map

        surface = drawMapSurface(map)
        ctx = Cairo.creategc(surface)
    
        surfaceStatus = status(surface)
        if surfaceStatus == Cairo.STATUS_NO_MEMORY
            warn_dialog("Not enough memory to save image.", Ahorn.window)
        end

        fn = Ahorn.hasExt(filename, ".png")? filename : filename * ".png"
        open(io -> write_to_png(surface, io), fn, "w")

        Cairo.destroy(ctx)
    end
end

end