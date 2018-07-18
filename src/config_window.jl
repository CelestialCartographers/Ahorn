module ConfigWindow

using Gtk, Gtk.ShortNames, Gtk.GConstants

struct Option{T}
    name::String
    dataType::Type
    startValue::T
    options::Union{Void, Array{T, 1}}
    editable::Bool
    dataName::String
    rowCount::Tuple{Int, Int}

    Option(name::String, dataType::Type, startValue::T=""; options::Union{Void, Array{T, 1}}=nothing, editable::Bool=true, dataName::String=name, rowCount::Tuple{Int, Int}=(0, 0)) where T = new{T}(name, dataType, startValue, options, editable, dataName, rowCount)
end

function sortScore(option::Option, lockedPositions::Array{String, 1}=String[])
    index = findfirst(lockedPositions, option.dataName)
    if index != 0
        return index - length(lockedPositions) - 1

    else
        dataType = option.dataType
        options = option.options

        if dataType == Bool
            return 2

        elseif dataType == String || dataType <: Number
            if options === nothing
                return 0

            else
                return 1
            end

        else
            return 3
        end
    end
end

function columnEditCallback(store, col, row, value)
    if typeof(store[row, col]) <: Number
        store[row, col] = parseNumber(value)

    else
        store[row, col] = value
    end
end

function addListRow(container::Main.ListContainer, option::Option, window::Gtk.GtkWindowLeaf)
    rows, cols = size(container.store)

    if rows + 1 > option.rowCount[2] && option.rowCount[2] != -1
        info_dialog("Adding a new row would result in too many rows", window)

        return false
    end

    push!(container.store, tuple([typ == String? "0" : zero(typ) for typ in eltype(container.data).parameters]...))
    select!(container, rows + 1)
end

function deleteListRow(container::Main.ListContainer, option::Option, window::Gtk.GtkWindowLeaf)
    rows, cols = size(container.store)

    if rows - 1 < option.rowCount[1]
        info_dialog("Deleting this row would result in too few rows", window)

        return false
    end

    if hasselection(container.selection)
        row = selected(container.selection)
        deleteat!(container.store, row)
    end
end

function addOptions!(window::Gtk.GtkWindowLeaf, grid::Gtk.GtkGridLeaf, options::Array{Option, 1}, cols::Integer)
    index = 0
    widgets = Tuple{Option, Any}[]
    
    for option in options
        if option.dataType === Bool
            row, col = divrem(index, cols)

            checkbox = CheckButton(option.name, active=isa(option.startValue, Bool) && option.startValue)
            grid[col, row] = checkbox
            push!(widgets, (option, checkbox))

            index += 1

        elseif option.dataType <: Array && eltype(option.dataType) <: Tuple
            row, col = divrem(index, cols)

            headers = tuple(split(option.name, ';')...)
            data = option.startValue

            container = Main.generateTreeView(headers, data, sortable=false, editable=fill(option.editable, length(headers)), callbacks=fill(columnEditCallback, length(headers)))
            scrollableWindow = ScrolledWindow(vexpand=true, hscrollbar_policy=Gtk.GtkPolicyType.NEVER)
            push!(scrollableWindow, container.tree)

            if option.editable
                addButton = Button("Add row")
                removeButton = Button("Delete row")

                buttonWidth = floor(Int, cols / 2)

                grid[0:buttonWidth - 1, row + 2] = addButton
                grid[buttonWidth:cols - 1, row + 2] = removeButton

                signal_connect(w -> addListRow(container, option, window), addButton, "clicked")
                signal_connect(w -> deleteListRow(container, option, window), removeButton, "clicked")
            end

            grid[0:cols - 1, row + 1] = scrollableWindow
            push!(widgets, (option, container))

            index = cols * (row + option.editable + 1)
        
        elseif option.dataType <: Number || option.dataType === String
            lrow, lcol = divrem(index, cols)
            erow, ecol = divrem(index + 1, cols)

            label = Label(" $(option.name) ")
            setproperty!(label, :xalign, 0.1)
            grid[lcol, lrow] = label

            if isa(option.options, Void)
                entry = Entry(text=string(option.startValue))

                grid[ecol, erow] = entry
                push!(widgets, (option, entry))

            else
                combo = ComboBoxText(option.editable)
                push!(combo, string.(option.options)...)
                setproperty!(combo, :active, findfirst(option.options, option.startValue) - 1)

                grid[ecol, erow] = combo
                push!(widgets, (option, combo))
            end

            index += 2
        end
    end

    return index, widgets
end

function parseNumber(n::String)
    try
        return parse(Int, n)

    catch
        # For locales with , as decimal sep
        return parse(Float64, replace(n, ",", "."))
    end
end

function getData(widgets)
    res = Dict{String, Any}()

    for (option, widget) in widgets
        if isa(widget, Gtk.GtkEntryLeaf)
            text = getproperty(widget, :text, String)

            if option.dataType <: Number
                res[option.dataName] = parseNumber(text)

            elseif option.dataType === Char
                # TODO - Error if string is > 1 char
                res[option.dataName] = text[1]

            else
                res[option.dataName] = text
            end

        elseif isa(widget, Gtk.GtkCheckButtonLeaf)
            res[option.dataName] = getproperty(widget, :active, Bool)

        elseif isa(widget, Gtk.GtkComboBoxTextLeaf)
            res[option.dataName] = Gtk.bytestring(Gtk.GAccessor.active_text(widget))

        elseif isa(widget, Main.ListContainer)
            res[option.dataName] = Main.getListData(widget)
        end
    end

    return res
end

function createWindow(title::String, options::Array{Option, 1}, callback::Function; sortOptions::Bool=true, cols::Integer=4, lockedPositions::Array{String, 1}=String[])
    window = Window(title, -1, -1, false, icon=Main.windowIcon, gravity=GdkGravity.GDK_GRAVITY_CENTER) |> (Frame() |> (box = Box(:v)))
    grid = Grid()

    if sortOptions
        sort!(options, by=option -> (sortScore(option, lockedPositions), option.name))
    end

    index, widgets = addOptions!(window, grid, options, cols)
    
    updateButton = Button("Update")
    function updateButtonCallback(widget)
        try
            callback(getData(widgets))

        catch
            info_dialog("One or more of the inputs were invalid.\nPlease make sure number fields have valid numbers.", window)
        end
    end
    signal_connect(updateButtonCallback, updateButton, "clicked")

    push!(box, grid)
    push!(box, updateButton)
    
    # Only make space for scrollable lists if they are present
    # height() lies about the height, but should be fine if there actually are scrollables
    scrollableCount = sum([isa(w, Main.ListContainer) for (o, w) in widgets])
    if scrollableCount > 0
        setproperty!(window, :height_request, height(window) + 100 * scrollableCount)
    end

    showall(window)

    return window
end

end
