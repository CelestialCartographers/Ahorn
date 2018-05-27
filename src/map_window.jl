using Gtk, Gtk.ShortNames
using Maple

function createNewMap(widget)
    button, name = input_dialog("Enter package name for new map", "11-Example", (("Cancel", 0), ("Create Map", 1)), window)

    if button == 1
        loadedState.filename = nothing
        loadedState.roomName = nothing
        loadedState.room = nothing

        loadedState.map = Map(name)
        
        updateTreeView!(roomList, getTreeData(loadedState.map))
        
        setproperty!(window, :title, "$baseTitle - $name")
    end
end