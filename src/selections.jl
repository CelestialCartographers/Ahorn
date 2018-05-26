selectionTargets = Dict{String, Function}(
    "entities" => room -> room.entities,
    "triggers" => room -> room.triggers,
    "bgDecals" => room -> room.bgDecals,
    "fgDecals" => room -> room.fgDecals
)

function getSelection(trigger::Maple.Trigger, node::Number=0)
    x, y = Int(trigger.data["x"]), Int(trigger.data["y"])
    width, height = Int(trigger.data["width"]), Int(trigger.data["height"])

    return true, Rectangle(x, y, width, height)
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
    targets = get(selectionTargets, name, room -> [])(room)

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

    return res
end

getSelected(room::Room, layer::Layer, selection::Rectangle) = getSelected(room, layerName(layer), selection)

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

function updateSelections!(selections::Set{Tuple{String, Rectangle, Any, Number}}, room::Room, name::String, rect::Rectangle; retain::Bool=false, best::Bool=false)
    # Holding shift keeps the last selection as well
    if !retain
        empty!(selections)
    end

    # Make sure the new selections are unique
    validSelections = getSelected(room, name, rect)
    if best
        target = bestSelection(validSelections)
        if target !== nothing
            set = Set{Tuple{String, Rectangle, Any, Number}}()
            push!(set, target)
            union!(selections, set)
        end

    else
        union!(selections, validSelections)
    end
end

updateSelections!(selections::Set{Tuple{String, Rectangle, Any, Number}}, room::Room, layer::Layer, rect::Rectangle) = updateSelections!(selections, room, layerName(layer), rect)