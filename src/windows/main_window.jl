canvas.is_realized = true
set_gtk_property!(canvas, :hexpand, true)
set_gtk_property!(canvas, :vexpand, true)
set_gtk_property!(canvas, :double_buffered, false)

scrollableWindowMaterialList = nothing
scrollableWindowRoomList = nothing

lastCanvasDraw = time()

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