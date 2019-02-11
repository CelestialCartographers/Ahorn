struct Cursor
    mx::Int
    my::Int

    max::Int
    may::Int

    x::Int
    y::Int

    ax::Int
    ay::Int

    Cursor(mx::Int, my::Int, max::Int, may::Int, x::Int, y::Int, ax::Int, ay::Int) = new(mx, my, max, may, x, y, ax, ay)

    function Cursor(event::eventMouse, camera::Camera, room::Maple.Room)
        mx, my = getMapCoordinates(camera, event.x, event.y)
        max, may = getMapCoordinatesAbs(camera, event.x, event.y)

        x, y = mapToRoomCoordinates(mx, my, room)
        ax, ay = mapToRoomCoordinatesAbs(max, may, room)

        return new(mx, my, max, may, x, y, ax, ay)
    end
end