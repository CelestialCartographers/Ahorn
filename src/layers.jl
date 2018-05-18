mutable struct Layer
    name::String
    surface::Cairo.CairoSurface
    redraw::Bool
    visible::Bool
    selectable::Bool

    Layer(name::String, surface::Cairo.CairoSurface=CairoARGBSurface(0, 0); redraw::Bool=true, visible::Bool=true, selectable::Bool=true) = new(name, surface, redraw, visible, selectable)
end

include("drawable_room.jl")

Base.isequal(lhs::Layer, rhs::Layer) = lhs.name == rhs.name

redrawingFuncs = Dict{String, Function}()

function redrawCanvas!()
    if isdefined(:canvas)
        draw(canvas)
    end
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
redrawLayer!(::Void) = false

layerName(l::Layer) = l.name
layerName(l::Void) = ""

function resetLayer!(layer::Layer, room::Room)
    if (Int(width(layer.surface)), Int(height(layer.surface))) != room.size
        Cairo.destroy(layer.surface)
        layer.surface = CairoARGBSurface(room.size...)
    end

    clearSurface(layer.surface)
end

resetLayer!(layer::Layer, room::DrawableRoom) = resetLayer!(layer, room.room)

function useIfApplicable(f, args...)
    if applicable(f, args...)
        f(args...)

        return true
    end

    return false
end

function combineLayers!(ctx::Cairo.CairoContext, layers::Array{Layer, 1}, camera::Camera, room::DrawableRoom; alpha::Number=getGlobalAlpha())
    for layer in layers
        if layer.redraw
            debug.log("Redrawing ($(layer.surface.width), $(layer.surface.height)) $(layer.name)", "DRAWING_VERBOSE")

            resetLayer!(layer, room)

            redrawFunc = get(redrawingFuncs, layer.name, (layer, room) -> true)

            # Use DrawableRoom if it accepts it, otherwise just a plain Maple Room
            success = useIfApplicable(redrawFunc, layer, room, camera) ||
                useIfApplicable(redrawFunc, layer, room) ||
                useIfApplicable(redrawFunc, layer, room.room, camera) ||
                useIfApplicable(redrawFunc, layer, room.room)

            layer.redraw = false
    
            debug.log("Done redrawing $(layer.name)", "DRAWING_VERBOSE")

            if get(debug.config, "DRAWING_LAYER_DUMP", false)
                write_to_png(layer.surface, "layersDump/$(room.map.package)_$(room.name)_$(layer.name).png")
            end
        end

        if layer.visible
            roomX, roomY = room.room.position
            applyLayer!(ctx, layer, alpha=alpha)
            debug.log("Applying $(layer.name)", "DRAWING_VERBOSE")
        end
    end
end

function applyLayer!(ctx::Cairo.CairoContext, layer::Layer, x::Integer=0, y::Integer=0; alpha::Number=getGlobalAlpha())
    drawImage(ctx, layer.surface, x, y, alpha=alpha)
end