mutable struct Camera
    x::Number
    y::Number
    scale::Number
    locked::Bool

    Camera(x::Number, y::Number, scale::Number) = new(x, y, scale, false)
end

function setCamera!(camera::Camera, x::Integer, y::Integer)
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

function zoomIn!(camera::Camera, event::Gtk.GdkEventScroll)
    updateCameraZoomVariables()

    if minimumZoom <= camera.scale * 2 <= maximumZoom
        camera.scale = camera.scale * 2
        camera.x = round(Int, camera.x * 2 + event.x)
        camera.y = round(Int, camera.y * 2 + event.y)

        draw(canvas)

        return true
    end

    return false
end

function zoomOut!(camera::Camera, event::Gtk.GdkEventScroll)
    updateCameraZoomVariables()

    if minimumZoom <= camera.scale / 2 <= maximumZoom
        camera.scale = camera.scale / 2
        camera.x = round(Int, (camera.x - event.x) / 2)
        camera.y = round(Int, (camera.y - event.y) / 2)

        return true
    end

    return false
end

minimumZoom = 2.0^-6
maximumZoom = 2.0^6
defaultZoom = 4