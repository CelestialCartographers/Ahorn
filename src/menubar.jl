module Menubar
using Gtk, Gtk.ShortNames

sampleMenuItemLeaf = Gtk.GtkMenuItemLeaf()

function generateMenubar(headers::Array{String, 1}, items::Array{Array{Tuple{String, Function}, 1}, 1})
    menubar = MenuBar()

    for (i, header) in enumerate(headers)
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

    return menubar
end

generateMenubar(headers::Tuple, items::Array{Array{Tuple{String, Function}, 1}, 1}) = generateMenubar(collect(headers), items)

end