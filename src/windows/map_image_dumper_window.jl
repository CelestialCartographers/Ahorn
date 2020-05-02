module MapImageDumper

using Maple, Cairo
using Gtk, Gtk.ShortNames
using ..Ahorn

surfaceSize(tlx::Number, tly::Number, brx::Number, bry::Number) = brx - tlx, bry - tly
surfaceSize(m::Maple.Map) = surfaceSize(Maple.bounds(m)...)

function drawMapSurface(m::Maple.Map)
    dummyMap = deepcopy(m)

    tlx, tly, brx, bry = Maple.bounds(dummyMap)
    width, height = surfaceSize(tlx, tly, brx, bry)

    camera = Ahorn.Camera(tlx, tly, 1)
    surface = Cairo.CairoARGBSurface(width, height)
    ctx = Ahorn.getSurfaceContext(surface)

    Ahorn.paintSurface(ctx, (1.0, 1.0, 1.0, 0.0))
    pattern_set_filter(get_source(ctx), Cairo.FILTER_NEAREST)

    for room in dummyMap.rooms
        dr = Ahorn.getDrawableRoom(dummyMap, room)
        dr.fillColor = (1.0, 1.0, 1.0, 0.0)

        Ahorn.getLayerByName(dr.layers, "triggers").visible = false
        Ahorn.getLayerByName(dr.layers, "tools").visible = false

        Ahorn.drawRoom(ctx, camera, dr, alpha=1.0)
    end

    Ahorn.deleteDrawableRoomCache(dummyMap)

    deleteSurface(surface)

    return surface
end

function dumpMapImageDialog(w=nothing)
    celesteDir = get(Ahorn.config, "celeste_dir", "")
    targetDir = ispath(celesteDir) ? celesteDir : pwd()
    
    map = Ahorn.loadedState.map

    if isa(map, Map)
        filename = Ahorn.saveDialog("Save as", Ahorn.window, ["*.png"], folder=targetDir)

        if filename != "" && isa(map, Map)
            surface = drawMapSurface(map)
            ctx = Ahorn.getSurfaceContext(surface)
        
            surfaceStatus = Cairo.status(surface)
            if surfaceStatus == Cairo.STATUS_NO_MEMORY
                warn_dialog("Not enough memory to save image.", Ahorn.window)

            else
                fn = Ahorn.hasExt(filename, ".png") ? filename : filename * ".png"
                open(io -> write_to_png(surface, io), fn, "w")
            end

            deleteSurface(surface)
        end

    else
        warn_dialog("No map is currently loaded.", Ahorn.window)
    end
end

end