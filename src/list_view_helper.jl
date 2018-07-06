mutable struct ListContainer
    store::Gtk.GtkListStore
    selection::Gtk.GtkTreeSelection
    tree::Gtk.GtkTreeView
    data::Array{Any, 1}
    visible::Array{Bool, 1}
end

columnTypes = Dict{Type, Any}(
    Array{String, 1} => GtkCellRendererCombo(),
    Bool => GtkCellRendererToggle(),
    Gtk.GdkPixbufLeaf => GtkCellRendererPixbuf()
)

columnNames = Dict{Type, Any}(
    Array{String, 1} => "combo",
    Bool => "active",
    Gtk.GdkPixbufLeaf => "pixbuf"
)

# Broken in Gtk.jl, redefined here
index_from_iter(store::GtkListStore, iter::Gtk.TRI) = parse(Int, Gtk.get_string_from_iter(GtkTreeModel(store), iter)) + 1

sanitizeListData(t::Tuple) = t
sanitizeListData(a::Array{T, 1}) where T <: Any = (isempty(a) && !(eltype(a) <: Tuple))? Tuple{String}[] : sanitizeListData.(a)
sanitizeListData(v::Any) = (v,)

function getSelected(list::ListContainer, default::Integer=1)
    if hasselection(list.selection)
        return index_from_iter(list.store, selected(list.selection))

    else
        return default
    end
end

function unselect!(list::ListContainer)
    if hasselection(list.selection)
        row = selected(list.selection)

        unselect!(list.selection, row)
    end
end

function Base.select!(list::ListContainer, i::Integer=1; force::Bool=false)
    if 1 <= i <= length(list.store) && (i != getSelected(list, -1) || force)
        Gtk.GLib.@sigatom select!(list.selection, Gtk.iter_from_index(list.store, i))

        return true
    end

    return false
end

function Base.select!(list::ListContainer, f::Function, default::Number=1; force::Bool=false)
    for i in 1:length(list.store)
        row = list.store[i]

        if f(row)
            Gtk.GLib.@sigatom select!(list, i, force=force)

            return true
        end
    end

    return Gtk.GLib.@sigatom select!(list, default, force=true)
end

function getListData!(container::ListContainer)
    return [container.store[i] for i in 1:length(container.store)]
end

function updateTreeViewUnsafe!(container::ListContainer, data::Array{T, 1}, select::Union{Integer, Function}=1, setData::Bool=true) where T <: Any
    data = sanitizeListData(data)

    if setData
        container.data = deepcopy(data)
        container.visible = fill(true, length(data))
    end

    # This makes sure nothing new is automaticly selected while emptying the store
    container.selection = GAccessor.mode(container.selection, Gtk.GConstants.GtkSelectionMode.NONE)

    empty!(container.store)

    for d in data
        push!(container.store, d)
    end

    container.selection = GAccessor.mode(container.selection, Gtk.GConstants.GtkSelectionMode.SINGLE)

    if !isempty(data)
        Gtk.GLib.@sigatom select!(container, select)
    end
end

# Default selection to current selected
updateTreeView!(
    container::ListContainer,
    data::Array{T, 1},
    select::Union{Integer, Function}=getSelected(container),
    setData::Bool=true
) where T <: Any = Gtk.GLib.@sigatom updateTreeViewUnsafe!(container, data, select, setData)

function filterContainer!(container::ListContainer)
    data = typeof(container.data)()

    for (i, d) in enumerate(container.data)
        if container.visible[i]
            push!(data, d)
        end
    end

    updateTreeView!(container, data, 1, false)
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

function generateTreeView(header::H, data::Array{T, 1}; resize::Bool=true, sortable::Bool=true, editable::Array{Bool, 1}=fill(false, length(header)), callbacks::Array{F, 1}=fill(false, length(header))) where {T <: Any, H <: Any, F <: Any}
    header = sanitizeListData(header)
    data = sanitizeListData(data)

    tupleTypes = eltype(data).parameters
    store = GtkListStore(tupleTypes...)

    for d in data
        push!(store, d)
    end

    treeView = GtkTreeView(GtkTreeModel(store))

    cols = GtkTreeViewColumn[]

    for c in 1:length(tupleTypes)
        col = GtkTreeViewColumn(
            header[c],
            get(columnTypes, tupleTypes[c], textRenderer(editable[c], (store, c, isa(callbacks[c], Function)? callbacks[c] : placeholderCallback))),
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

    push!(treeView, cols...)

    selection = GAccessor.selection(treeView)

    return ListContainer(store, selection, treeView, deepcopy(data), fill(true, length(data)))
end

function connectChanged(container::ListContainer, f::Function)
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

function getTreeData(m::Union{Maple.Map, Void}, simple::Bool=get(config, "use_simple_room_values", true))
    data = Tuple{String, Int, Int, Int, Int}[]

    if isa(m, Maple.Map)
        for room in m.rooms
            if simple
                push!(data, (room.name, round.(Int, room.position ./ 8)..., round.(Int, room.size ./ 8)...))

            else
                push!(data, (room.name, room.position..., room.size...))
            end
        end
    end

    return data
end