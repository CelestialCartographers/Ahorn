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
    callbacks=listViewCallbackUnion[
        function(store, col, row, v)
            if v != ""
                room = Maple.getRoomByName(loadedState.map, store[row, 1])
                wantedRoom = Maple.getRoomByName(loadedState.map, v)

                if isa(wantedRoom, Maple.Room) && room != wantedRoom
                    info_dialog("The selected room name is already in use.", window)

                else
                    store[row, col] = v

                    room.name = v

                    loadedState.room = room
                    loadedState.roomName = v
                    
                    persistence["files_lastroom"] = v
                end
            end
        end,
        function(store, col, row, v)
            try
                newX = parse(Int, v)
                room = Maple.getRoomByName(loadedState.map, store[row, 1])
                x, y = room.position

                simple = get(config, "use_simple_room_values", true)
                multiplier = simple ? 8 : 1

                room.position = (newX * multiplier, y)
                store[row, col] = newX

                draw(canvas)

            catch

            end
        end,
        function(store, col, row, v)
            try
                newY = parse(Int, v)
                room = Maple.getRoomByName(loadedState.map, store[row, 1])
                x, y = room.position

                simple = get(config, "use_simple_room_values", true)
                multiplier = simple ? 8 : 1

                room.position = (x, newY * multiplier)
                store[row, col] = newY

                draw(canvas)

            catch 
                
            end
        end,
        false,
        false
    ]
)

function roomListRowHandler(list::ListContainer, row)
    selected = row[1]

    if selected != loadedState.roomName
        previousRoom = loadedState.room

        loadedState.roomName = selected
        loadedState.room = getRoomByName(loadedState.map, loadedState.roomName)
        persistence["files_lastroom"] = loadedState.roomName

        reset!(camera)
        setCamera!(camera, loadedState.room.position...)
        updateDrawingLayers!(loadedState.map, loadedState.room)

        handleRoomChanged(loadedState.map, loadedState.room, previousRoom)

        draw(canvas)
    end
end

connectChanged(roomListRowHandler, roomList)

function selectLoadedRoom!(roomList::ListContainer)
    # Select the specified room or the first one
    if loadedState.room !== nothing
        selectRow!(roomList, r -> r[1] == loadedState.roomName)

    else
        selectRow!(roomList)
    end
end

function showAllRoomListColumns()
    set_gtk_property!.(roomList.cols, :visible, true)

    persistence["room_list_column_visibility"] = "all"
end

function showRoomListNameColumn()
    set_gtk_property!(roomList.cols[1], :visible, true)
    set_gtk_property!.(roomList.cols[2:end], :visible, false)

    persistence["room_list_column_visibility"] = "roomOnly"
end

function hideAllRoomListColumns()
    set_gtk_property!.(roomList.cols, :visible, false)

    persistence["room_list_column_visibility"] = "none"
end


roomListVisiblityIndices = [
    "all",
    "roomOnly",
    "none"
]

roomListVisiblityFunctions = Dict{String, Function}(
    "all" => showAllRoomListColumns,
    "roomOnly" => showRoomListNameColumn,
    "none" => hideAllRoomListColumns
)

function getRoomListVisibilityRadioIndex()
    return something(findfirst(isequal(get(persistence, "room_list_column_visibility", "all")), roomListVisiblityIndices), 1)
end