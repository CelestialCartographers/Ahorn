roomList = generateTreeView(("Room", "X", "Y", "Width", "Height"), getTreeData(loadedMap))
connectChanged(roomList, function(roomList, row)
    selected = row[1]    

    if selected != selectedRoom
        global selectedRoom = selected
        global loadedRoom = getRoomByName(loadedMap, selectedRoom)
        reset!(camera)
        setCamera!(camera, loadedRoom.position...)
        updateDrawingLayers!(loadedMap, loadedRoom)

        handleRoomChanged(loadedMap, loadedRoom)

        draw(canvas)
    end
end)