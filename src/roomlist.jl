roomList = generateTreeView(
    ("Room", "X", "Y", "Width", "Height"),
    getTreeData(loadedState.map),
    editable=Bool[
        true,
        true,
        true,
        false,
        false
    ],
    callbacks=[
        function(store, col, row, v)
            if v != ""
                room = Maple.getRoomByName(loadedState.map, store[row, 1])
                room.name = v
                store[row, col] = v
            end
        end,
        function(store, col, row, v)
            try
                newX = parse(Int, v)
                room = Maple.getRoomByName(loadedState.map, store[row, 1])
                x, y = room.position

                simple = get(config, "use_simple_room_values", true)
                multiplier = simple? 8 : 1

                room.position = (newX * multiplier, y)
                store[row, col] = newX

                draw(canvas)
            end
        end,
        function(store, col, row, v)
            try
                newY = parse(Int, v)
                room = Maple.getRoomByName(loadedState.map, store[row, 1])
                x, y = room.position

                simple = get(config, "use_simple_room_values", true)
                multiplier = simple? 8 : 1

                room.position = (x, newY * multiplier)
                store[row, col] = newY

                draw(canvas)
            end
        end,
        false,
        false
    ]
)
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

function selectLoadedRoom!(roomList::ListContainer)
    # Select the specified room or the first one
    if loadedState.room !== nothing
        select!(roomList, r -> r[1] == loadedState.roomName)

    else
        select!(roomList)
    end
end