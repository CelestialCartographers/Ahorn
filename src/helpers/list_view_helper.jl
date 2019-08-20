mutable struct ListContainer{T}
    store::Gtk.GtkListStore
    selection::Gtk.GtkTreeSelection
    tree::Gtk.GtkTreeView
    cols::Array{Gtk.GtkTreeViewColumn, 1}
    data::Array{T, 1}
    dataType::DataType
    visible::Array{Bool, 1}
end

const columnTypes = Dict{Type, Gtk.GObject}(
    Array{String, 1} => GtkCellRendererCombo(),
    Bool => GtkCellRendererToggle(),
    Gtk.GdkPixbufLeaf => GtkCellRendererPixbuf()
)

const columnNames = Dict{Type, String}(
    Array{String, 1} => "combo",
    Bool => "active",
    Gtk.GdkPixbufLeaf => "pixbuf"
)

const listViewCallbackUnion = Union{Bool, Function}
const listViewSelectUnion = Union{Integer, Function, Nothing}

# Broken in Gtk.jl, redefined here
index_from_iter(store::GtkListStore, iter::Gtk.TRI) = parse(Int, Gtk.get_string_from_iter(GtkTreeModel(store), iter)) + 1

sanitizeListData(t::Tuple) = t
sanitizeListData(a::Array{<: Tuple, 1}) = sanitizeListData.(a)
sanitizeListData(a::Array{T, 1}) where T = Tuple{T}[sanitizeListData(v) for v in a]
sanitizeListData(v) = (v,)

function getSelected(list::ListContainer, default::Union{Integer, Nothing}=nothing)
    if hasselection(list.selection)
        return index_from_iter(list.store, selected(list.selection))

    else
        return default
    end
end

function unselectRow!(list::ListContainer)
    if hasselection(list.selection)
        row = selected(list.selection)

        Gtk.unselect!(list.selection, row)
    end
end

function currentRow(list::ListContainer)
    if hasselection(list.selection)
        return index_from_iter(list.store, selected(list.selection))
    
    else
        return 0
    end
end

function selectRow!(list::ListContainer, i::Integer=1; force::Bool=false)
    if 1 <= i <= length(list.store) && (i != getSelected(list, -1) || force)
        Gtk.GLib.@sigatom Gtk.select!(list.selection, Gtk.iter_from_index(list.store, i))

        return true
    end

    return false
end

function selectRow!(list::ListContainer, f::Function, default::Number=1; force::Bool=false)
    for i in 1:length(list.store)
        row = list.store[i]

        if f(row)
            selectRow!(list, i, force=force)

            return true
        end
    end

    return selectRow!(list, default, force=true)
end

function getListData(container::ListContainer)
    return container.dataType[container.store[i] for i in 1:length(container.store)]
end

# Default to currently selected
function unsafeUpdateTreeView!(container::ListContainer{T}, data::Array{T, 1}, select::listViewSelectUnion=1; setData::Bool=true, updateByReplacement::Bool=false) where T <: Tuple
    rows, cols = size(container.store)

    if setData
        container.data = deepcopy(data)
        container.visible = fill(true, length(data))
    end

    # This makes sure nothing new is automaticly selected while emptying the store
    container.selection = GAccessor.mode(container.selection, Gtk.GConstants.GtkSelectionMode.NONE)

    if updateByReplacement
        if rows > length(data)
            for i in 1:rows - length(data)
                Gtk.GLib.@sigatom deleteat!(container.store, rows - i + 1)
            end
        end

        for (i, row) in enumerate(data)
            if i <= rows
                for j in 1:length(row)
                    container.store[i, j] = row[j]
                end

            else
                push!(container.store, row)
            end
        end

    else
        empty!(container.store)

        for row in data
            push!(container.store, row)
        end
    end

    container.selection = GAccessor.mode(container.selection, Gtk.GConstants.GtkSelectionMode.SINGLE)

    if !isempty(data) && select !== nothing
        Gtk.GLib.@sigatom selectRow!(container, select)
    end
end

function updateTreeView!(container::ListContainer, data::Array{T, 1}, select::listViewSelectUnion=1; setData::Bool=true, updateByReplacement::Bool=false) where T
    data = isempty(data) ? container.dataType[] : sanitizeListData.(data)
    Gtk.GLib.@sigatom unsafeUpdateTreeView!(container, data, select; setData=setData, updateByReplacement=updateByReplacement)
end

function filterContainer!(container::ListContainer, select::listViewSelectUnion=1)
    updateTreeView!(container, container.data[container.visible], select, setData=false)
end

function placeholderCallback(store, col, row, text)

end

function textRenderer(editable::Bool=false, callback::Tuple{GtkListStore, Integer, Function}=(GtkListStore(String), 1, placeholderCallback))
    renderer = GtkCellRendererText(editable=editable)
    @guarded signal_connect(renderer, :edited) do widget, row, text
        store, col, func = callback

        func(store, col, parse(Int, row) + 1, text)
    end

    return renderer
end

correctTupleType(::Type{Bool}) = Bool
correctTupleType(::Type{<: Integer}) = Int
correctTupleType(::Type{<: Real}) = Float64
correctTupleType(type::Type{T}) where T = type

function generateTreeView(header::Union{NTuple{N, String}, String}, data::Array{T, 1}; resize::Bool=true, sortable::Bool=true, editable::Array{Bool, 1}=fill(false, length(header)), callbacks::Array{listViewCallbackUnion, 1}=Array{listViewCallbackUnion, 1}(fill(false, length(header))), visible::Array{Bool, 1}=fill(true, length(header))) where {N, T <: Tuple}
    header = sanitizeListData(header)
    data = sanitizeListData(data)

    tupleTypesRaw = eltype(data).parameters
    tupleTypes = correctTupleType.(tupleTypesRaw)
    store = GtkListStore(tupleTypes...)

    for d in data
        push!(store, d)
    end

    treeView = GtkTreeView(GtkTreeModel(store))

    cols = GtkTreeViewColumn[]

    for c in 1:length(tupleTypes)
        col = GtkTreeViewColumn(
            header[c],
            get(columnTypes, tupleTypes[c], textRenderer(editable[c], (store, c, isa(callbacks[c], Function) ? callbacks[c] : placeholderCallback))),
            Dict(get(columnNames, tupleTypes[c], "text") => c - 1)
        )

        push!(cols, col)
    end

    if resize
        for col in cols
            GAccessor.resizable(col, true)
        end
    end

    if sortable
        for (i, col) in enumerate(cols)
            GAccessor.sort_column_id(col, i - 1)
            GAccessor.reorderable(col, i - 1)
        end
    end

    append!(treeView, cols)

    selection = GAccessor.selection(treeView)
    set_gtk_property!.(cols, :visible, visible)

    return ListContainer{T}(store, selection, treeView, cols, deepcopy(data), Tuple{tupleTypes...}, fill(true, length(data)))
end

function connectChanged(f::Function, container::ListContainer)
    @guarded signal_connect(container.selection, "changed") do widget
        if hasselection(container.selection)
            row = selected(container.selection)

            if applicable(f, container, container.store[row]...)
                f(container, container.store[row]...)

            else
                f(container, container.store[row])
            end
        end
    end
end

function connectDoubleClick(container::ListContainer, f::Function)
    @guarded signal_connect(container.tree, "row-activated") do widget, box, col
        if hasselection(container.selection)
            row = selected(container.selection)

            if applicable(f, container, container.store[row]...)
                f(container, container.store[row]...)

            else
                f(container, container.store[row])
            end
        end
    end
end