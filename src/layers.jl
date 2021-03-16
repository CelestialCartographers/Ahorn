mutable struct Layer
    name::String
    drawFunction::Function
    surface::Cairo.CairoSurface
    redraw::Bool
    visible::Bool
    selectable::Bool
    dummy::Bool
    clearOnReset::Bool

    function Layer(name::String, drawFunction::Function=defaultRedrawingFunction, surface::Union{Cairo.CairoSurface, Nothing}=nothing; redraw::Bool=true, visible::Bool=true, selectable::Bool=true, dummy::Bool=false, clearOnReset::Bool=true)
        return new(name, drawFunction, surface === nothing ? CairoARGBSurface(0, 0) : surface, redraw, visible, selectable, dummy, clearOnReset) 
    end
end

include("drawable_room.jl")

Base.:(==)(lhs::Layer, rhs::Layer) = lhs.name == rhs.name
Base.hash(l::Layer, h::UInt) = hash(l.name, h)

const redrawingFuncs = Dict{String, Function}()

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

function layerSurfaceInvalid(layer::Layer)
    return layer.surface.ptr == C_NULL
end

function resetLayer!(layer::Layer, room::Room)
    canvasWidth, canvasHeight = Int(width(layer.surface)), Int(height(layer.surface))

    if layerSurfaceInvalid(layer) || canvasWidth != room.size[1] || canvasHeight != room.size[2]
        deleteSurface(layer.surface)
        layer.surface = CairoARGBSurface(room.size[1], room.size[2])
    end

    if layer.clearOnReset
        clearSurface(getSurfaceContext(layer.surface))
    end
end

resetLayer!(layer::Layer, room::DrawableRoom) = resetLayer!(layer, room.room)

const globalLayerVisibility = Dict{String, Bool}()

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

function drawLayer(layer::Layer, room::DrawableRoom)
    if !layer.dummy && (layerSurfaceInvalid(layer) || layer.redraw)
        resetLayer!(layer, room)

        @catchall begin
            layer.drawFunction(layer, room, camera)

            layer.redraw = false
        end
    end
end

function combineLayers!(ctx::Cairo.CairoContext, layers::Array{Layer, 1}, camera::Camera, room::DrawableRoom; alpha=nothing)
    for layer in layers
        drawLayer(layer, room)

        layerVisible = layer.visible && get!(globalLayerVisibility, layer.name, true)

        if layerVisible && !layer.dummy
            applyLayer!(ctx, layer, alpha=alpha)
        end
    end
end

function applyLayer!(ctx::Cairo.CairoContext, layer::Layer, x=0, y=0; alpha=nothing)
    drawImage(ctx, layer.surface, x, y, alpha=alpha)
end