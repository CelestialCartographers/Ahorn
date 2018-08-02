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

struct Section
    name::String
    dataName::String
    options::Array{Option, 1}
    fieldOrders::Array{String, 1}
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
        store[row, col] = Main.parseNumber(value)

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

function addOptions!(window::Gtk.GtkWindowLeaf, grid::Gtk.GtkGridLeaf, options::Array{Option, 1}, cols::Integer, index::Integer=0)
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

            label = Label(" $(option.name) ", xalign=0.0, margin_start=8)
            grid[lcol, lrow] = label

            if isa(option.options, Void) || isempty(option.options)
                startValue = option.startValue
                entry = Main.ValidationEntry(startValue)

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


function setDataAttr!(data::Dict{String, Any}, option::Option, value::Bool)
    data[option.dataName] = value
end

function setDataAttr!(data::Dict{String, Any}, option::Option, value::String)
    if option.dataType <: Number
        data[option.dataName] = Main.parseNumber(value)

    elseif option.dataType === Char
        # TODO - Error if string is > 1 char
        data[option.dataName] = value[1]

    else
        data[option.dataName] = value
    end
end

function setDataAttr!(data::Dict{String, Any}, option::Option, value::Main.ListContainer)
    data[option.dataName] = Main.getListData(value)
end

function getData(widgets)
    res = Dict{String, Any}()

    for (option, widget) in widgets
        if isa(widget, Gtk.GtkEntryLeaf)
            setDataAttr!(res, option, getproperty(widget, :text, String))

        elseif isa(widget, Gtk.GtkCheckButtonLeaf)
            setDataAttr!(res, option, getproperty(widget, :active, Bool))

        elseif isa(widget, Gtk.GtkComboBoxTextLeaf)
            setDataAttr!(res, option, Gtk.bytestring(Gtk.GAccessor.active_text(widget)))

        elseif isa(widget, Main.ListContainer)
            setDataAttr!(res, option, widget)
        end
    end

    return res
end

function addSectionWidgets!(window::Gtk.GtkWindowLeaf, section::Section; grid::Gtk.GtkGrid=Grid(), index::Integer=0, cols::Integer=4, sortOptions::Bool=true)
    index = ceil(Int, index / cols) * cols

    if !isempty(section.name)
        row, col = divrem(index + 1, cols)

        text = "<big><u>$(section.name)</u></big>"
        label = Label(text, use_markup=true)
        
        grid[0:cols - 1, row] = label
        index += cols
    end

    if sortOptions
        sort!(section.options, by=option -> (sortScore(option, section.fieldOrders), option.name))
    end

    index, widgets = addOptions!(window, grid, section.options, cols, index)

    return grid, widgets, index
end

function createWindow(title::String, sections::Array{Section, 1}, callback::Function; sortOptions::Bool=true, cols::Integer=4, alignCols::Bool=true)
    window = Window(title, -1, -1, false, icon=Main.windowIcon, gravity=GdkGravity.GDK_GRAVITY_CENTER) |> (Frame() |> (box = Box(:v)))
    grid = Grid()
    index = 0

    sectionWidgets = Dict{String, Array{Any, 1}}()

    for section in sections
        sectionGrid, widgets, index = addSectionWidgets!(window, section, grid=alignCols? grid : Grid(), index=index, cols=cols, sortOptions=sortOptions)
        sectionWidgets[section.dataName] = widgets

        if !alignCols
            push!(box, sectionGrid)
        end
    end
    
    updateButton = Button("Update")
    function updateButtonCallback(widget)
        try
            # Special case for singular unnamed section
            if length(sections) == 1 && isempty(sections[1].dataName)
                callback(getData(sectionWidgets[""]))
            
            else
                res = Dict{String, Dict{String, Any}}()

                for (sectionName, widgets) in sectionWidgets
                    if isempty(sectionName) && length(sections) == 1
                        res = getData(widgets)

                    else
                        res[sectionName] = getData(widgets)
                    end
                end

                callback(res)
            end

        catch e
            println(e)
            info_dialog("One or more of the inputs are invalid.\nPlease make sure number fields have valid numbers.", window)
        end
    end
    signal_connect(updateButtonCallback, updateButton, "clicked")

    if alignCols
        push!(box, grid)
    end

    push!(box, updateButton)
    
    # Only make space for scrollable lists if they are present
    # height() lies about the height, but should be fine if there actually are scrollables
    scrollableCount = 0
    for (name, widgets) in sectionWidgets
        scrollableCount += sum([isa(w, Main.ListContainer) for (o, w) in widgets])
    end

    if scrollableCount > 0
        setproperty!(window, :height_request, height(window) + 100 * scrollableCount)
    end

    return window
end

# Wrapper for single section window
function createWindow(title::String, options::Array{Option, 1}, callback::Function; sortOptions::Bool=true, cols::Integer=4, lockedPositions::Array{String, 1}=String[])
    section = Section("", "", options, lockedPositions)

    return createWindow(title, Section[section], callback, sortOptions=sortOptions, cols=cols)
end

end
