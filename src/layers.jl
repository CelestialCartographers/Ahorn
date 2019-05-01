mutable struct Layer
    name::String
    surface::Cairo.CairoSurface
    redraw::Bool
    visible::Bool
    selectable::Bool
    dummy::Bool
    clearOnReset::Bool

    Layer(name::String, surface::Cairo.CairoSurface=CairoARGBSurface(0, 0); redraw::Bool=true, visible::Bool=true, selectable::Bool=true, dummy::Bool=false, clearOnReset::Bool=true) = new(name, surface, redraw, visible, selectable, dummy, clearOnReset)
end

include("drawable_room.jl")

Base.:(==)(lhs::Layer, rhs::Layer) = lhs.name == rhs.name

redrawingFuncs = Dict{String, Function}()

function redrawCanvas!()
    draw(canvas)
end

function getLayerByName(layers::Array{Layer, 1}, name::String, default::String="")
    for layer in layers
        if layer.name == name
            return layer
        end
    end

    if default !== nothing || default != ""
        return getLayerByName(layers, default)
    end

    return false
end

function redrawLayer!(layer::Layer)
    layer.redraw = true

    redrawCanvas!()
end

# Void redraw because layers might not be set yet in tools
redrawLayer!(layers::Array{Layer, 1}, name::String) = redrawLayer!(getLayerByName(layers, name))
redrawLayer!(::Nothing) = false

layerName(l::Layer) = l.name
layerName(l::Nothing) = ""

function resetLayer!(layer::Layer, room::Room)
    if layer.surface.ptr == C_NULL
        print("Null surface")
        layer.surface = CairoARGBSurface(room.size...)
    end

    if (Int(width(layer.surface)), Int(height(layer.surface))) != room.size
        Cairo.destroy(layer.surface)
        layer.surface = CairoARGBSurface(room.size...)
    end

    if layer.clearOnReset
        clearSurface(layer.surface)
    end
end

resetLayer!(layer::Layer, room::DrawableRoom) = resetLayer!(layer, room.room)

globalLayerVisibility = Dict{String, Bool}()

function setGlobalLayerVisiblity(canvas::Gtk.GtkCanvas, name::String, visible::Bool=true)
    if get!(globalLayerVisibility, name, true) != visible
        globalLayerVisibility[name] = visible

        # Make sure all relevant layers are marked for redraw
        for (map, data) in drawableRooms
            for (room, dr) in data
                layer = getLayerByName(dr.layers, name)

                layer.redraw = true
            end
        end

        draw(canvas)
    end
end

function setGlobalLayerVisiblity(name::String, widget::Gtk.GtkCheckMenuItem)
    setGlobalLayerVisiblity(canvas, name, get_gtk_property(widget, :active, Bool))
end

function combineLayers!(ctx::Cairo.CairoContext, layers::Array{Layer, 1}, camera::Camera, room::DrawableRoom; alpha::Number=getGlobalAlpha())
    for layer in layers
        if layer.redraw && !layer.dummy
            debug.log("Redrawing ($(layer.surface.width), $(layer.surface.height)) $(layer.name)", "DRAWING_VERBOSE")

            resetLayer!(layer, room)

            redrawFunc = get(redrawingFuncs, layer.name, (layer, room) -> true)

            # Use DrawableRoom if it accepts it, otherwise just a plain Maple Room
            @catchall begin
                success = useIfApplicable(redrawFunc, layer, room, camera) ||
                    useIfApplicable(redrawFunc, layer, room) ||
                    useIfApplicable(redrawFunc, layer, room.room, camera) ||
                    useIfApplicable(redrawFunc, layer, room.room)

                layer.redraw = false
            end
    
            debug.log("Done redrawing $(layer.name)", "DRAWING_VERBOSE")
        end

        if layer.visible && !layer.dummy && get!(globalLayerVisibility, layer.name, true)
            applyLayer!(ctx, layer, alpha=alpha)
            debug.log("Applying $(layer.name)", "DRAWING_VERBOSE")
        end
    end
end

function applyLayer!(ctx::Cairo.CairoContext, layer::Layer, x::Integer=0, y::Integer=0; alpha::Number=getGlobalAlpha())
    drawImage(ctx, layer.surface, x, y, alpha=alpha)
end