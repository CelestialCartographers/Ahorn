module Menubar
using Gtk, Gtk.ShortNames

sampleMenuItemLeaf = Gtk.GtkMenuItemLeaf()

# Doesn't seem like we can hide items after they are added
# Use this workaround instead
function generateMenubar(headers::Array{String, 1}, items::Array{Array{Tuple{String, Function}, 1}, 1}, hidden::Array{String, 1}=String[])
    menubar = MenuBar()

    for (i, header) in enumerate(headers)
        if !(header in hidden)
            headerItem = MenuItem(header)
            headerSection = Menu(headerItem)

            for data in items[i]
                name, func = data

                dataItem = MenuItem(name)
                push!(headerSection, dataItem)
                signal_connect(func, dataItem, :activate)
            end

            push!(menubar, headerItem)
        end
    end

    return menubar
end

generateMenubar(headers::Tuple, items::Array{Array{Tuple{String, Function}, 1}, 1}, hidden::Array{String, 1}=String[]) = generateMenubar(collect(headers), items, hidden)

end