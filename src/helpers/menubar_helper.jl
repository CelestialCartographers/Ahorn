module Menubar
using Gtk, Gtk.ShortNames, Gtk.GConstants
using ..Ahorn

abstract type AbstractMenuItem

end

struct MenuChoice <: AbstractMenuItem
    name::String
    func::Function
    image::Union{Gtk.GtkImage, Nothing}

    function MenuChoice(name::String, func::Function, image::Union{Gtk.GtkImage, Nothing}=nothing)
        return new(name, func, image)
    end
end

struct MenuSeparator <: AbstractMenuItem

end

struct MenuChoices <: AbstractMenuItem
    name::String
    children::Array{AbstractMenuItem, 1}
    image::Union{Gtk.GtkImage, Nothing}

    function MenuChoices(name::String, children::Array{AbstractMenuItem, 1}, image::Union{Gtk.GtkImage, Nothing}=nothing)
        return new(name, children, image)
    end
end

struct MenuRadioGroup <: AbstractMenuItem
    names::Array{String, 1}
    funcs::Union{Function, Array{Function, 1}}
    start::Union{Function, Int}

    function MenuRadioGroup(names::Array{String, 1}, func::Function, index::Union{Function, Int}=1)
        return new(names, func, index)
    end

    function MenuRadioGroup(rows::Array{Tuple{String, Function}, 1}, index::Union{Function, Int}=1)
        return new(getindex.(rows, 1), getindex.(rows, 2), index)
    end
end

struct MenuCheck <: AbstractMenuItem
    name::String
    callback::Function
    start::Union{Function, Bool}

    function MenuCheck(name::String, callback::Function, start::Union{Function, Bool}=false)
        return new(name, callback, start)
    end
end

function generateMenubarItem(choice::Union{MenuChoice, MenuChoices})
    return choice.image === nothing ? Ahorn.ImageMenuItem(choice.name) : Ahorn.ImageMenuItem(choice.name, choice.image)
end

function addMenubarItem!(choices::MenuChoices, parent)
    item = generateMenubarItem(choices)
    section = Menu(item)

    for child in choices.children
        addMenubarItem!(child, section)
    end

    push!(parent, item)
end

function addMenubarItem!(choice::MenuChoice, parent)
    item = generateMenubarItem(choice)

    push!(parent, item)
    signal_connect(choice.func, item, :activate)
end

function addMenubarItem!(choice::MenuSeparator, parent)
    push!(parent, SeparatorMenuItem())
end

function addMenubarItem!(choice::MenuRadioGroup, parent)
    radios = Gtk.GtkRadioMenuItem[]
    groupRadio = Ahorn.RadioMenuItem(choice.names[1])

    push!(radios, groupRadio)

    wantedIndex = isa(choice.start, Int) ? choice.start : choice.start()

    for (i, name) in enumerate(choice.names[2:end])
        radio = Ahorn.RadioMenuItem(name, groupRadio)

        if i == wantedIndex - 1
            set_gtk_property!(radio, :active, true)
        end

        push!(radios, radio)
    end

    Ahorn.connectRadioGroupSignal(choice.funcs, radios)

    for radio in radios
        push!(parent, radio)
    end
end

function addMenubarItem!(choice::MenuCheck, parent)
    checkItem = Ahorn.CheckMenuItem(choice.name)
    value = isa(choice.start, Bool) ? choice.start : choice.start()

    set_gtk_property!(checkItem, :active, value)
    signal_connect(choice.callback, checkItem, "toggled")

    push!(parent, checkItem)
end

function generateMenubar(choices::Array{AbstractMenuItem, 1})
    menubar = MenuBar()

    for choice in choices
        addMenubarItem!(choice, menubar)
    end

    return menubar
end

end