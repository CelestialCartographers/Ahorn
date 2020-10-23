mutable struct Camera
    x::Number
    y::Number
    scale::Number
    locked::Bool

    Camera(x::Number, y::Number, scale::Number) = new(x, y, scale, false)
end

function setCamera!(camera::Camera, x, y)
    if !camera.locked
        camera.x = x * camera.scale
        camera.y = y * camera.scale
    end
end

function reset!(camera::Camera, force::Bool=false)
    if !camera.locked || force
        camera.x = 0
        camera.y = 0
        camera.scale = defaultZoom
    end
end

function lock!(camera::Camera)
    camera.locked = true
end

function unlock!(camera::Camera)
    camera.locked = false
end

function updateCameraZoomVariables()
    global minimumZoom = 2.0^round(Int, log(2, get(config, "camera_minimum_zoom", minimumZoom)))
    global maximumZoom = 2.0^round(Int, log(2, get(config, "camera_maximum_zoom", maximumZoom)))
    global defaultZoom = 2.0^round(Int, log(2, get(config, "camera_default_zoom", defaultZoom)))
end

function zoomIn!(camera::Camera, x::Number, y::Number)
    updateCameraZoomVariables()

    if minimumZoom <= camera.scale * 2 <= maximumZoom
        camera.scale = camera.scale * 2
        camera.x = round(Int, camera.x * 2 + x)
        camera.y = round(Int, camera.y * 2 + y)

        draw(canvas)

        return true
    end

    return false
end

zoomIn!(camera::Camera, event::Gtk.GdkEventScroll) = zoomIn!(camera, event.x, event.y)
zoomIn!(camera::Camera=camera) = zoomIn!(camera, width(canvas) / 2, height(canvas) / 2)

function zoomOut!(camera::Camera, x::Number, y::Number)
    updateCameraZoomVariables()

    if minimumZoom <= camera.scale / 2 <= maximumZoom
        camera.scale = camera.scale / 2
        camera.x = round(Int, (camera.x - x) / 2)
        camera.y = round(Int, (camera.y - y) / 2)

        draw(canvas)

        return true
    end

    return false
end

zoomOut!(camera::Camera, event::Gtk.GdkEventScroll) = zoomOut!(camera, event.x, event.y)
zoomOut!(camera::Camera=camera) = zoomOut!(camera, width(canvas) / 2, height(canvas) / 2)

minimumZoom = 2.0^-6
maximumZoom = 2.0^6
defaultZoom = 4