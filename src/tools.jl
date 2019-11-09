include("brush.jl")

const loadedTools = joinpath.(abs"tools", readdir(abs"tools"))
loadModule.(loadedTools)
currentTool = nothing

function getToolName(tool::String)
    if hasModuleField(tool, "displayName")
        return getModuleField(tool, "displayName")

    elseif haskey(loadedModules, tool)
        return repr(loadedModules[tool])
    end
end

function getToolGroup(tool::String)
    if hasModuleField(tool, "group")
        return getModuleField(tool, "group")

    elseif haskey(loadedModules, tool)
        return "Unknown"
    end
end

toolDisplayNames = Dict{String, String}()
function updateToolDisplayNames!(tools::Array{String, 1})
    global toolDisplayNames = Dict{String, String}(
        getToolName(tool) => tool for tool in loadedTools if haskey(loadedModules, tool)
    )
end

subtoolList = generateTreeView("Mode", Tuple{String}[], sortable=false)
connectChanged(subtoolList) do list::ListContainer, selected::String
    eventToModule(currentTool, "subToolSelected", list, selected)
end

layersList = generateTreeView(("Layer",), Tuple{String}[], sortable=false)
connectChanged(layersList) do list::ListContainer, selected::String
    eventToModule(currentTool, "layerSelected", list, selected)
    eventToModule(currentTool, "layerSelected", list, selected)
    eventToModule(currentTool, "layerSelected", list, materialList, selected)
    eventToModule(currentTool, "layerSelected", list, materialList, selected)

    updateMaterialFilter!(selected)
end

materialList = generateTreeView("Material", Tuple{String}[], sortable=false)
connectChanged(materialList) do list::ListContainer, selected::String
    eventToModule(currentTool, "materialSelected", list, selected)
end

function updateMaterialFilter!(layer::String)
    if get(config, "keep_search_text_per_layer", true)
        # Force event to trigger by first changing the text to blank
        searchText = get(persistence, "material_search_$layer", "")
        Gtk.GLib.@sigatom GAccessor.text(materialFilterEntry, "")
        Gtk.GLib.@sigatom GAccessor.text(materialFilterEntry, searchText)
    
    else
        Gtk.GLib.@sigatom GAccessor.text(materialFilterEntry, "")
    end
end

function changeTool!(tool::String)
    if loadedState.map !== nothing && loadedState.room !== nothing
        dr = getDrawableRoom(loadedState.map, loadedState.room)

        if currentTool !== nothing
            eventToModule(currentTool, "cleanup")
        end

        if tool in loadedTools
            global currentTool = tool
        
        elseif haskey(toolDisplayNames, tool)
            global currentTool = toolDisplayNames[tool]
        end
        
        # Clear the subtool and material list
        # Tools need to set up this themselves
        updateTreeView!(subtoolList, [])
        updateTreeView!(materialList, [])

        eventToModule(currentTool, "layersChanged", dr.layers)
        eventToModule(currentTool, "toolSelected")
        eventToModule(currentTool, "toolSelected", subtoolList, layersList, materialList)
    end
end

function getSortedToolNames(tools::Array{String, 1})
    res = Tuple{String, String}[]
    for tool in tools
        group, name = getToolGroup(tool), getToolName(tool)
        
        if group !== nothing && name !== nothing
            push!(res, (group, name))
        end
    end
    
    sort!(res)

    return String[r[2] for r in res]
end

toolList = generateTreeView("Tool", Tuple{String}[], sortable=false)
connectChanged(toolList) do list::ListContainer, selected::String
    debug.log("Selected $selected", "TOOLS_SELECTED")
    changeTool!(selected)
end

function updateToolList!(list::ListContainer)
    updateTreeView!(list, getSortedToolNames(loadedTools), 1)
end

function selectionRectangle(x1::Number, y1::Number, x2::Number, y2::Number)
    drawX = min(x1, x2)
    drawW = abs(x1 - x2) + 1

    drawY = min(y1, y2)
    drawH = abs(y1 - y2) + 1

    return Rectangle(drawX, drawY, drawW, drawH)
end

function updateSelectionByCoords!(map::Map, ax::Number, ay::Number)
    room = Maple.getRoomByCoords(map, ax, ay)

    if room != false && room.name != loadedState.roomName
        selectRow!(roomList, row -> row[1] == room.name)
        handleRoomChanged(Ahorn.loadedState.map, Ahorn.loadedState.room)
    
        return true
    end

    return false
end

function notifyMaterialsFiltered(text::String)
    eventToModule(currentTool, "materialFiltered", materialList)
    eventToModule(currentTool, "materialFiltered", materialList, text)
end

function selectMaterialList!(m::String)
    selectRow!(materialList, row -> row[1] == m)
end

function setMaterialList!(materials::Array{String, 1}, selector::listViewSelectUnion=nothing)
    if selector !== nothing
        updateTreeView!(materialList, materials, selector)
    
    else
        updateTreeView!(materialList, materials)
    end
end

function selectLayer!(layers::Array{Layer, 1}, layer::String, default::String="")
    newLayer = getLayerByName(layers, layer, default)
    selectRow!(layersList, row -> row[1] == newLayer.name)

    return newLayer
end

selectLayer!(layers::Array{Layer, 1}, layer::Union{Layer, Nothing}, default::String="") = selectLayer!(layers, layerName(layer), default)

function updateLayerList!(names::Array{String, 1}, selector::listViewSelectUnion=getSelected(layersList))
    if selector !== nothing
        updateTreeView!(layersList, names, selector)
    
    else
        updateTreeView!(layersList, names)
    end
end

function handleSelectionMotion(start::eventMouse, startCamera::Camera, current::eventMouse)
    room = loadedState.room
    
    mx1, my1 = getMapCoordinates(startCamera, start.x, start.y)
    mx2, my2 = getMapCoordinates(camera, current.x, current.y)

    max1, may1 = getMapCoordinatesAbs(startCamera, start.x, start.y)
    max2, may2 = getMapCoordinatesAbs(camera, current.x, current.y)

    x1, y1 = mapToRoomCoordinates(mx1, my1, room)
    x2, y2 = mapToRoomCoordinates(mx2, my2, room)

    ax1, ay1 = mapToRoomCoordinatesAbs(max1, may1, room)
    ax2, ay2 = mapToRoomCoordinatesAbs(max2, may2, room)

    # Grid Based coordinates
    eventToModule(currentTool, "selectionMotion", selectionRectangle(x1, y1, x2, y2))
    eventToModule(currentTool, "selectionMotion", x1, y1, x2, y2)

    # Absolute coordinates
    eventToModule(currentTool, "selectionMotionAbs", selectionRectangle(ax1, ay1, ax2, ay2))
    eventToModule(currentTool, "selectionMotionAbs", ax1, ay1, ax2, ay2)
end

function handleSelectionFinish(start::eventMouse, startCamera::Camera, current::eventMouse, currentCamera::Camera)
    room = loadedState.room
    
    mx1, my1 = getMapCoordinates(startCamera, start.x, start.y)
    mx2, my2 = getMapCoordinates(currentCamera, current.x, current.y)

    max1, may1 = getMapCoordinatesAbs(startCamera, start.x, start.y)
    max2, may2 = getMapCoordinatesAbs(currentCamera, current.x, current.y)

    x1, y1 = mapToRoomCoordinates(mx1, my1, room)
    x2, y2 = mapToRoomCoordinates(mx2, my2, room)

    ax1, ay1 = mapToRoomCoordinatesAbs(max1, may1, room)
    ax2, ay2 = mapToRoomCoordinatesAbs(max2, may2, room)

    # Grid Based coordinates
    eventToModule(currentTool, "selectionFinish", selectionRectangle(x1, y1, x2, y2))
    eventToModule(currentTool, "selectionFinish", x1, y1, x2, y2)

    # Absolute coordinates
    eventToModule(currentTool, "selectionFinishAbs", selectionRectangle(ax1, ay1, ax2, ay2))
    eventToModule(currentTool, "selectionFinishAbs", ax1, ay1, ax2, ay2)
end

function getMouseEventName(event::eventMouse, downEvent::eventMouse)
    prefix = get(mouseTypePrefix, downEvent.event_type, "")
    handle = mouseHandlers[event.button]

    if !isempty(prefix)
        return prefix * uppercasefirst(handle)
    
    else
        return handle
    end
end

function handleClicks(event::eventMouse, camera::Camera, downEvent::eventMouse)
    if haskey(mouseHandlers, event.button)
        handle = getMouseEventName(event, downEvent)
        room = loadedState.room

        mx, my = getMapCoordinates(camera, event.x, event.y)
        max, may = getMapCoordinatesAbs(camera, event.x, event.y)

        x, y = mapToRoomCoordinates(mx, my, room)
        ax, ay = mapToRoomCoordinatesAbs(max, may, room)

        lock!(camera)
        if !updateSelectionByCoords!(loadedState.map, max, may)
            # Teleport to cursor 
            if EverestRcon.loaded && event.button == 0x1 && modifierControl() && modifierAlt()
                url = get(config, "everest_rcon", "http://localhost:32270")
                room = loadedState.roomName
                EverestRcon.reload(url, room)
                EverestRcon.teleportToRoom(url, room, ax, ay)

            else
                eventToModule(currentTool, handle)
                eventToModule(currentTool, handle, event, camera)
                eventToModule(currentTool, handle, x, y)
                eventToModule(currentTool, handle * "Abs", ax, ay)
            end
        end
        unlock!(camera)
    end
end

function handleMotion(event::eventMouse, camera::Camera)
    room = loadedState.room

    mx, my = getMapCoordinates(camera, event.x, event.y)
    max, may = getMapCoordinatesAbs(camera, event.x, event.y)

    x, y = mapToRoomCoordinates(mx, my, room)
    ax, ay = mapToRoomCoordinatesAbs(max, may, room)

    eventToModule(currentTool, "mouseMotion", event, camera)
    eventToModule(currentTool, "mouseMotion", x, y)
    eventToModule(currentTool, "mouseMotionAbs", event, camera)
    eventToModule(currentTool, "mouseMotionAbs", ax, ay)
end

function toolChangeCallback(index)
    sortedToolNames = getSortedToolNames(loadedTools)
    if length(sortedToolNames) >= index
        changeTool!(sortedToolNames[index])
        selectRow!(toolList, index)

        return true
    end

    return false
end

function roomMoveCallback(direction::String)
    keyval = getfield(Gtk.GdkKeySyms, Symbol(direction))
    History.addSnapshot!(History.RoomSnapshot("Room Movement", loadedState.room))
    
    ox, oy = moveDirections[keyval] .* 8
    loadedState.room.position = loadedState.room.position .+ (ox, oy)
    updateTreeView!(roomList, getTreeData(loadedState.map), row -> row[1] == loadedState.room.name, updateByReplacement=true)

    draw(canvas)

    return true
end

function deleteRoomCallback(widget=nothing)
    index = findfirst(isequal(loadedState.room), loadedState.map.rooms)
    
    if index !== nothing && ask_dialog("Are you sure you want to delete this room? '$(loadedState.room.name)'", window)
        History.addSnapshot!(History.MapSnapshot("Room Deletion", loadedState.map))

        deleteat!(loadedState.map.rooms, index)
        updateTreeView!(roomList, getTreeData(loadedState.map))
        draw(canvas)

        return true
    end

    return false
end

debugHotkeys = Tuple{Hotkey, String}[
    (Hotkey("F1", debug.reloadTools!), "Reloading tools"),
    (Hotkey("F2", () -> debug.reloadEntities!() && debug.reloadTriggers!()), "Reloading entities and triggers"),
    (Hotkey("F3", debug.clearMapDrawingCache!), "Deleting room render caches"),
]

# 10 is ctrl + 0
toolChangeHotkeys = Hotkey[
    Hotkey("ctrl + $(i % 10)", () -> toolChangeCallback(i)) for i in 1:10
]

roomModificationHotkeys = vcat(
    Hotkey[Hotkey("alt + $key", () -> roomMoveCallback(key)) for key in String["Left", "Up", "Right", "Down"]],
    Hotkey[Hotkey("alt + Delete", deleteRoomCallback)]
)

function handleDebugKeys(event::eventKey)
    if get(debug.config, "ENABLE_HOTSWAP_HOTKEYS", false)
        for (hotkey, desc) in debugHotkeys
            if active(hotkey, event)
                println("! $desc")

                callback(hotkey)

                return true
            end
        end
    end

    return false
end

function handleHotkeyToolChange(event::eventKey)
    return callbackFirstActive(toolChangeHotkeys, event)
end

function handleRoomModifications(event::eventKey)
    if loadedState.room !== nothing && loadedState.map !== nothing
        return callbackFirstActive(roomModificationHotkeys, event)
    end

    return false
end

function handleKeyPressed(event::eventKey, sendToToolModules::Bool=true)
    # Handle in this order, until one of them consumes the event
    return handleDebugKeys(event) ||
        handleRoomModifications(event) ||
        handleHotkeyToolChange(event) ||
        sendToToolModules && eventToModule(currentTool, "keyboard", event)
end

function handleKeyReleased(event::eventKey)

end

function handleRoomChanged(map::Map, room::Union{Nothing, Room}, previousRoom::Union{Nothing, Room}=nothing)
    # Clean up tools layer before notifying about room change
    eventToModule(currentTool, "cleanup")

    if isa(room, Room)
        dr = getDrawableRoom(map, room)

        eventToModule(currentTool, "roomChanged", room)
        eventToModule(currentTool, "roomChanged", map, room)
        eventToModule(currentTool, "layersChanged", dr.layers)
    end

    if isa(previousRoom, Room)
        dr = getDrawableRoom(map, previousRoom)
        layer = getLayerByName(dr.layers, "tools")

        clearSurface(layer.surface)
        layer.redraw = true

        redrawLayer!(dr.rendering)
    end
end