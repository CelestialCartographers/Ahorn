mutable struct ListContainer
    store::Gtk.GtkListStore
    selection::Gtk.GtkTreeSelection
    tree::Gtk.GtkTreeView
end

columnTypes = Dict{Type, Any}(
    Bool => GtkCellRendererToggle(),
    Gtk.GdkPixbufLeaf => GtkCellRendererPixbuf()
)

columnNames = Dict{Type, Any}(
    Bool => "active",
    Gtk.GdkPixbufLeaf => "pixbuf"
)

sanitizeListData(t::Tuple) = t
sanitizeListData(a::Array{T, 1}) where T <: Any = (isempty(a) && !(eltype(a) <: Tuple))? Tuple{String}[] : sanitizeListData.(a)
sanitizeListData(v::Any) = (v,)

function unselect!(list::ListContainer)
    if hasselection(list.selection)
        row = selected(list.selection)

        unselect!(list.selection, row)
    end
end

function Base.select!(list::ListContainer, i::Integer=1)
    if 1 <= i <= length(list.store)
        Gtk.GLib.@sigatom select!(list.selection, Gtk.iter_from_index(list.store, i))

        return true
    end

    return false
end

function Base.select!(list::ListContainer, f::Function, default::Number=1)
    for i in 1:length(list.store)
        row = list.store[i]

        if f(row)
            Gtk.GLib.@sigatom select!(list, i)

            return true
        end
    end

    Gtk.GLib.@sigatom select!(list, default)
    return false
end

function updateTreeViewUnsafe!(container::ListContainer, data::Array{T, 1}, select::Union{Integer, Function}=1) where T <: Any
    data = sanitizeListData(data)

    # This makes sure nothing new is automaticly selected while emptying the store
    container.selection = GAccessor.mode(container.selection, Gtk.GConstants.GtkSelectionMode.NONE)

    empty!(container.store)

    for d in data
        push!(container.store, d)
    end

    container.selection = GAccessor.mode(container.selection, Gtk.GConstants.GtkSelectionMode.SINGLE)

    # Select an item based on value or function
    Gtk.GLib.@sigatom select!(container, select)
end

updateTreeView!(container::ListContainer, data::Array{T, 1}, select::Union{Integer, Function}=1) where T <: Any = Gtk.GLib.@sigatom updateTreeViewUnsafe!(container, data, select)

function generateTreeView(header::H, data::Array{T, 1}; resize::Bool=true, sortable::Bool=true) where {T <: Any, H <: Any}
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
            get(columnTypes, tupleTypes[c], GtkCellRendererText()),
            Dict([(get(columnNames, tupleTypes[c], "text"), c - 1)])
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

    return ListContainer(store, selection, treeView)
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