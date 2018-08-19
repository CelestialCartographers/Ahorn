baseTitle = "Ahorn α"
iconFile = abs"../docs/logo-256-a.png"
logoFile = abs"../docs/logo-1024-a.png"

windowIcon = Pixbuf(filename=iconFile, width=-1, height=-1, preserve_aspect_ratio=true)
box = Box(:v)

canvas.is_realized = true
setproperty!(canvas, :hexpand, true)
setproperty!(canvas, :vexpand, true)

scrollableWindowMaterialList = nothing
scrollableWindowRoomList = nothing

@guarded draw(canvas) do widget
    if loadedState.map !== nothing && isa(loadedState.map, Map)
        startTime = time()

        drawMap(canvas, camera, loadedState.map)

        stopTime = time()
        deltaTime = stopTime - startTime
        debug.log("Drawing canvas took $deltaTime seconds", "DRAWING_CANVAS_DRAW_DURATION")

        persistence["camera_position_x"] = camera.x
        persistence["camera_position_y"] = camera.y
        persistence["camera_scale"] = camera.scale
    end
end

function generateMainGrid()
    grid = Grid()

    global scrollableWindowRoomList = ScrolledWindow(vexpand=true, hscrollbar_policy=Gtk.GtkPolicyType.NEVER)
    push!(scrollableWindowRoomList, roomList.tree)

    global scrollableWindowMaterialList = ScrolledWindow(vexpand=true, hscrollbar_policy=Gtk.GtkPolicyType.NEVER)
    push!(scrollableWindowMaterialList, materialList.tree)

    grid[1:6, 1] = menubar
    grid[1, 2:3] = scrollableWindowRoomList
    grid[2, 2:3] = canvas
    grid[3, 2:3] = toolList.tree
    grid[4, 2:3] = layersList.tree
    grid[5, 2:3] = subtoolList.tree
    grid[6, 2] = scrollableWindowMaterialList
    grid[6, 3] = materialFilterEntry

    return grid
end