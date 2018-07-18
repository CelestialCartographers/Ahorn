lockedEntityEditingFields = ["x", "y", "width", "height"]

function displayProperties(x::Number, y::Number, room::Maple.Room, targetLayer::Layer)
    rect = Rectangle(x, y, 1, 1)
    selection = bestSelection(getSelected(room, targetLayer, rect))

    if selection !== nothing
        layer, box, target, node = selection
        if layer == "entities" || layer == "triggers"
            function callback(data::Dict{String, Any})
                History.addSnapshot!(History.RoomSnapshot("Properties", room))
                target.data = deepcopy(data)
                redrawLayer!(targetLayer)
            end
            
            options = entityConfigOptions(target)
            ConfigWindow.createWindow("$(baseTitle) - Editing $(target.name):$(target.id)", options, callback, lockedPositions=lockedEntityEditingFields)
        end
    end
end