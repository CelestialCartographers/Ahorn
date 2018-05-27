roomList = generateTreeView(("Room", "X", "Y", "Width", "Height"), getTreeData(loadedState.map))
connectChanged(roomList, function(roomList, row)
    selected = row[1]

    if selected != loadedState.roomName
        loadedState.roomName = selected
        loadedState.room = getRoomByName(loadedState.map, loadedState.roomName)
        persistence["files_lastroom"] = loadedState.roomName

        reset!(camera)
        setCamera!(camera, loadedState.room.position...)
        updateDrawingLayers!(loadedState.map, loadedState.room)

        handleRoomChanged(loadedState.map, loadedState.room)

        draw(canvas)
    end
end)