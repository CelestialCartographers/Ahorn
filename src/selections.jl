mutable struct TileSelection
    fg::Bool
    tiles::Array{Char, 2}
    selection::Rectangle
    startX::Number
    startY::Number
    offsetX::Number
    offsetY::Number
end

TileSelection(fg::Bool, tiles::Array{Char, 2}, selection::Rectangle) = TileSelection(fg, tiles, selection, selection.x, selection.y, 0, 0)

selectableLayers = ["fgTiles", "bgTiles", "entities", "triggers", "fgDecals", "bgDecals"]
selectionTargets = Dict{String, Function}(
    "entities" => room -> room.entities,
    "triggers" => room -> room.triggers,
    "bgDecals" => room -> room.bgDecals,
    "fgDecals" => room -> room.fgDecals
)

function getSelection(trigger::Maple.Trigger, node::Number=0)
    x, y = Int(trigger.data["x"]), Int(trigger.data["y"])
    width, height = Int(trigger.data["width"]), Int(trigger.data["height"])
    nodes = get(trigger.data, "nodes", Tuple{Integer, Integer}[])

    if isempty(nodes)
        return true, Rectangle(x, y, width, height)

    else
        res = Rectangle[Rectangle(x, y, width, height)]

        for node in nodes
            nx, ny = Int.(node)
            push!(res, Rectangle(nx, ny, width, height))
        end

        return true, res
    end
end

function getSelection(decal::Maple.Decal, node::Number=0)
    return true, decalSelection(decal)
end

function getSelection(entity::Maple.Entity, node::Number=0)
    selectionRes = eventToModules(loadedEntities, "selection", entity) 

    if isa(selectionRes, Tuple)
        success, rect = selectionRes

        if success
            return true, rect
        end
    end

    return false, false
end

function getSelection(target::TileSelection, node::Number=0)
    return true, target.selection
end

# TODO - Use mouse position and check if its closer to the center as well
# Area is "good enough" for now
function bestSelection(set::Set{Tuple{String, Rectangle, Any, Number}})
    best = nothing
    bestVal = typemax(Int)

    for selection in set
        layer, rect, target, node = selection
        area = rect.w * rect.h

        if area < bestVal
            best = selection
            bestVal = area
        end
    end

    return best
end

function getSelected(room::Room, name::String, selection::Rectangle)
    res = Set{Tuple{String, Rectangle, Any, Number}}()

    # Rectangular based selection - Triggers, Entities, Decals
    if haskey(selectionTargets, name)
        targets = selectionTargets[name](room)

        for target in targets
            success, rect = getSelection(target)

            if success
                if isa(rect, Rectangle)
                    if checkCollision(selection, rect)
                        push!(res, (name, rect, target, 0))
                    end

                elseif isa(rect, Array{Rectangle, 1})
                    for (i, r) in enumerate(rect)
                        if checkCollision(selection, r)
                            # The first rect is the main entity itself, followed by the nodes
                            push!(res, (name, r, target, i - 1))
                        end
                    end
                end
            end
        end

    # Tile based selections
    elseif name == "fgTiles" || name == "bgTiles"
        fg = name == "fgTiles"
        tiles = fg? room.fgTiles.data : room.bgTiles.data

        tx, ty = floor(Int, selection.x / 8), floor(Int, selection.y / 8)
        tw, th = ceil(Int, selection.w / 8), ceil(Int, selection.h / 8) 

        gx, gy = tx * 8, ty * 8
        gw, gh = tw * 8, th * 8
        gridSelection = Rectangle(gx, gy, gw, gh)

        drawingTiles = fill('0', (th + 2, tw + 2))
        drawingTiles[2:end - 1, 2:end - 1] = get(tiles, (ty + 1:ty + th, tx + 1:tx + tw), '0')

        target = TileSelection(
            fg,
            drawingTiles,
            gridSelection
        )

        push!(res, (name, gridSelection, target, 0))
    end

    return res
end

getSelected(room::Room, layer::Layer, selection::Rectangle) = getSelected(room, layerName(layer), selection)

# Currently no support for tiles
function getFilteredSelections(selections::Set{Tuple{String, Rectangle, Any, Number}}, rect::Rectangle, room::Room, name::String, func::Function)
    res = Set{Tuple{String, Rectangle, Any, Number}}()

    success, best = hasSelectionAt(selections, rect)
    if !success
        return res
    end
    
    # Rectangular based selection - Triggers, Entities, Decals
    if haskey(selectionTargets, name)
        targets = selectionTargets[name](room)

        for target in targets
            success, rect = getSelection(target)

            if success
                if isa(rect, Rectangle)
                    if func(best, target)
                        push!(res, (name, rect, target, 0))
                    end

                elseif isa(rect, Array{Rectangle, 1})
                    for (i, r) in enumerate(rect)
                        if func(best, target)
                            # The first rect is the main entity itself, followed by the nodes
                            push!(res, (name, r, target, i - 1))
                        end
                    end
                end
            end
        end
    end

    return res
end

function getFilteredSelections(selections::Set{Tuple{String, Rectangle, Any, Number}}, rect::Rectangle, room::Room, layer::Layer, func::Function)
    return getFilteredSelections(selections, rect, room, layerName(layer), func)
end

# Return a function that can compare the base target with all the other targets
# Returning true if they are "same-ish"
function getFilterFunction(name::String, strict::Bool=false)
    if name == "entities" || name == "trigger"
        # Strict mode is all flags the same, excluding x, y and nodes
        # Normal mode is just name

        if strict
            return function(base::Union{Entity, Trigger}, target::Union{Entity, Trigger})
                # Don't count nodes as a key
                if (length(base.data) - haskey(base.data, "nodes")) != (length(target.data) - haskey(target.data, "nodes"))
                    return false
                end

                if base.name != target.name
                    return false
                end

                for (k, v) in base.data
                    if k == "x" || k == "y" || k == "nodes"
                        continue
                    end

                    if get(target.data, k, nothing) != v
                        return false
                    end
                end

                return true
            end

        else
            return function(base::Union{Entity, Trigger}, target::Union{Entity, Trigger})
                return base.name == target.name
            end
        end

    elseif name == "bgDecals" || name == "fgDecals"
        # Strict mode is same scales as well as texture
        # Normal mode is just texture

        if strict
            return function(base::Decal, target::Decal)
                return base.texture == target.texture && base.scaleX == target.scaleX && base.scaleY == target.scaleY
            end

        else
            return function(base::Decal, target::Decal)
                return base.texture == target.texture
            end
        end
    end

    return function(base, target)
        return false
    end
end

getFilterFunction(layer::Layer, strict::Bool=false) = getFilterFunction(layerName(layer), strict)

function hasSelectionAt(selections::Set{Tuple{String, Rectangle, Any, Number}}, rect::Rectangle)
    for selection in selections
        layer, box, target, node = selection

        success, targetRect = getSelection(target)
        if isa(targetRect, Rectangle) && checkCollision(rect, targetRect) && node == 0
            return true, target

        elseif isa(targetRect, Array{Rectangle, 1})
            for (i, r) in enumerate(targetRect)
                if checkCollision(rect, r) && node == i - 1
                    return true, target
                end
            end
        end
    end

    return false, false
end

function updateSelections!(selections::Set{Tuple{String, Rectangle, Any, Number}}, room::Room, name::String, rect::Rectangle; retain::Bool=false, best::Bool=false, mass::Bool=false)
    # Return selections that are no longer selected
    unselected = Set{Tuple{String, Rectangle, Any, Number}}()
    newlySelected = Set{Tuple{String, Rectangle, Any, Number}}()

    # Holding shift keeps the last selection as well
    if !retain
        unselected = deepcopy(selections)
        empty!(selections)
    end

    validSelections = Set{Tuple{String, Rectangle, Any, Number}}()
    if name == "all"
        for n in selectableLayers
            if mass
                func = getFilterFunction(n, best)
                union!(validSelections, getFilteredSelections(retain? selections : unselected, rect, room, n, func))

            else
                union!(validSelections, getSelected(room, n, rect))
            end
        end

    else
        if mass
            func = getFilterFunction(name, best)
            union!(validSelections, getFilteredSelections(retain? selections : unselected, rect, room, name, func))

        else
            union!(validSelections, getSelected(room, name, rect))
        end
    end

    if best && !mass
        target = bestSelection(validSelections)
        if target !== nothing
            push!(selections, target)
            push!(newlySelected, target)
        end

    else
        union!(selections, validSelections)
        union!(newlySelected, validSelections)
    end

    return unselected, newlySelected
end

function fixSelections(room::Maple.Room, selections::Set{Tuple{String, Rectangle, Any, Number}})
    res = Set{Tuple{String, Rectangle, Any, Number}}()

    for selection in selections
        layer, box, target, node = selection
        if haskey(selectionTargets, layer)
            targets = selectionTargets[layer](room)

            index = findfirst(isequal(target), targets)
            if index > 0
                push!(res, (layer, box, targets[index], node))
            end

        else
            push!(res, (layer, box, target, node))
        end
    end

    return res
end

updateSelections!(selections::Set{Tuple{String, Rectangle, Any, Number}}, room::Room, layer::Layer, rect::Rectangle) = updateSelections!(selections, room, layerName(layer), rect)