@valueequals mutable struct TileSelection
    fg::Bool
    tiles::Array{Char, 2}
    selection::Rectangle
    startX::Number
    startY::Number
    offsetX::Number
    offsetY::Number
end

@valueequals mutable struct SelectedObject
    layerName::String
    rectangle::Rectangle
    target
    node::Int
end

TileSelection(fg::Bool, tiles::Array{Char, 2}, selection::Rectangle) = TileSelection(fg, tiles, selection, selection.x, selection.y, 0, 0)

deleted(tiles::TileSelection, node::Int) = nothing

moved(tiles::TileSelection) = nothing
moved(tiles::TileSelection, x::Int, y::Int) = nothing

resized(tiles::TileSelection) = nothing
resized(tiles::TileSelection, width::Int, height::Int) = nothing

function flipped(tiles::TileSelection, horizontal::Bool)
    tiles.tiles = reverse(tiles.tiles, dims=horizontal ? 2 : 1)

    return tiles
end

function rotated(tiles::TileSelection, steps::Int)
    rotationFunc = steps > 0 ? rotr90 : rotl90

    for i in 1:abs(steps) % 4
        tiles.tiles = rotationFunc(tiles.tiles)
    end

    # -16 to remove air padding around the tiles
    height, width = size(tiles.tiles)
    tiles.selection = Rectangle(tiles.selection.x, tiles.selection.y, width * 8 - 16, height * 8 - 16)

    return tiles
end

const selectableLayers = ["fgTiles", "bgTiles", "entities", "triggers", "fgDecals", "bgDecals"]
const selectionTargets = Dict{String, Function}(
    "entities" => room -> room.entities,
    "triggers" => room -> room.triggers,
    "bgDecals" => room -> room.bgDecals,
    "fgDecals" => room -> room.fgDecals
)

function getSelection(trigger::Maple.Trigger, room::Maple.Room, node::Number=0)
    return triggerSelection(trigger, room, node)
end

function getSelection(decal::Maple.Decal, room::Maple.Room, node::Number=0)
    return decalSelection(decal)
end

function getSelection(entity::Maple.Entity, room::Maple.Room, node::Number=0)
    return entitySelection(entity, room, node)
end

function getSelection(target::TileSelection, room::Maple.Room, node::Number=0)
    return target.selection
end

function position(target::TileSelection)
    return target.startX, target.startY
end

# TODO - Use mouse position and check if its closer to the center as well
# Area is "good enough" for now
function bestSelection(set::Set{SelectedObject})
    best = nothing
    bestVal = typemax(Int)

    for selection in set
        rect = selection.rectangle
        area = rect.w * rect.h

        if area < bestVal
            best = selection
            bestVal = area
        end
    end

    return best
end

# Do nothing on Bool
function getSelectedFromTarget!(res::Set{SelectedObject}, rect::Bool, selection::Rectangle, layerName, target)

end

function getSelectedFromTarget!(res::Set{SelectedObject}, rect::Rectangle, selection::Rectangle, layerName, target)
    if checkCollision(selection, rect)
        push!(res, SelectedObject(layerName, rect, target, 0))
    end
end

function getSelectedFromTarget!(res::Set{SelectedObject}, rects::Array{Rectangle, 1}, selection::Rectangle, layerName, target)
    # The first rect is the main entity itself, followed by the nodes
    for (i, r) in enumerate(rects)
        if checkCollision(selection, r)
            push!(res, SelectedObject(layerName, r, target, i - 1))
        end
    end
end

function getSelected(room::Room, name::String, selection::Rectangle)
    res = Set{SelectedObject}()

    # Rectangular based selection - Triggers, Entities, Decals
    if haskey(selectionTargets, name)
        targets = selectionTargets[name](room)

        for target in targets
            rect = getSelection(target, room)

            getSelectedFromTarget!(res, rect, selection, name, target)
        end

    # Tile based selections
    elseif name == "fgTiles" || name == "bgTiles"
        fg = name == "fgTiles"
        tiles = fg ? room.fgTiles.data : room.bgTiles.data

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
        
        push!(res, SelectedObject(name, gridSelection, target, 0))
    end

    return res
end

getSelected(room::Room, layer::Layer, selection::Rectangle) = getSelected(room, layerName(layer), selection)

# Do nothing on Bool
function addSelectionIfValid(res::Set{SelectedObject}, rect::Bool, func, best, layerName, target) 

end

function addSelectionIfValid(res::Set{SelectedObject}, rect::Rectangle, func, best, layerName, target) 
    if func(best, target)
        push!(res, SelectedObject(layerName, rect, target, 0))
    end
end

function addSelectionIfValid(res::Set{SelectedObject}, rects::Array{Rectangle, 1}, func, best, layerName, target) 
    for (i, r) in enumerate(rects)
        if func(best, target)
            # The first rect is the main entity itself, followed by the nodes
            push!(res, SelectedObject(layerName, r, target, i - 1))
        end
    end
end

# Currently no support for tiles
function getFilteredSelections(selections::Set{SelectedObject}, rect::Rectangle, room::Room, name::String, func::Function)
    res = Set{SelectedObject}()

    best = hasSelectionAt(selections, rect, room)
    if best == false
        return res
    end
    
    # Rectangular based selection - Triggers, Entities, Decals
    if haskey(selectionTargets, name)
        targets = selectionTargets[name](room)

        for target in targets
            rect = getSelection(target, room)

            addSelectionIfValid(res, rect, func, best, name, target)
        end
    end

    return res
end

function getFilteredSelections(selections::Set{SelectedObject}, rect::Rectangle, room::Room, layer::Layer, func::Function)
    return getFilteredSelections(selections, rect, room, layerName(layer), func)
end

# Return a function that can compare the base target with all the other targets
# Returning true if they are "same-ish"
function getFilterFunction(name::String, strict::Bool=false)
    if name == "entities" || name == "triggers"
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

function findSelectionAt(targetRect::Rectangle, rect, target, node)
    if checkCollision(rect, targetRect) && node == 0
        return target
    end
end

function findSelectionAt(targetRect::Array{Rectangle, 1}, rect, target, node)
    for (i, r) in enumerate(targetRect)
        if checkCollision(rect, r) && node == i - 1
            return target
        end
    end
end

function hasSelectionAt(selections::Set{SelectedObject}, rect::Rectangle, room::Room)
    for selection in selections
        targetRect = getSelection(selection.target, room)
        res = findSelectionAt(targetRect, rect, selection.target, selection.node)

        if res !== nothing
            return res
        end
    end

    return false
end

function updateSelections!(selections::Set{SelectedObject}, room::Room, name::String, rect::Rectangle; retain::Bool=false, best::Bool=false, mass::Bool=false)
    # Return selections that are no longer selected
    unselected = Set{SelectedObject}()
    newlySelected = Set{SelectedObject}()

    # Holding shift keeps the last selection as well
    if !retain
        unselected = deepcopy(selections)
        empty!(selections)
    end

    validSelections = Set{SelectedObject}()
    if name == "all"
        for n in selectableLayers
            if mass
                func = getFilterFunction(n, best)
                union!(validSelections, getFilteredSelections(retain ? selections : unselected, rect, room, n, func))

            else
                union!(validSelections, getSelected(room, n, rect))
            end
        end

    else
        if mass
            func = getFilterFunction(name, best)
            union!(validSelections, getFilteredSelections(retain ? selections : unselected, rect, room, name, func))

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

function fixSelections(room::Maple.Room, selections::Set{SelectedObject})
    res = Set{SelectedObject}()

    #for (layer, box, target, node) in selections
    for selection in selections
        layer = selection.layerName

        if haskey(selectionTargets, layer)
            targets = selectionTargets[layer](room)

            index = findfirst(isequal(selection.target), targets)
            if index !== nothing
                push!(res, SelectedObject(layer, selection.rectangle, targets[index], selection.node))
            end

        else
            push!(res, selection)
        end
    end

    return res
end

updateSelections!(selections::Set{SelectedObject}, room::Room, layer::Layer, rect::Rectangle) = updateSelections!(selections, room, layerName(layer), rect)

# TODO - Verify that scales are respected properly
function getSpriteRectangle(texture::String, x::Number, y::Number; jx::Number=0.5, jy::Number=0.5, sx::Number=1, sy::Number=1)
    sprite = getTextureSprite(texture)
    
    width, height = sprite.width, sprite.height
    realWidth, realHeight = sprite.realWidth, sprite.realHeight

    drawX, drawY = floor(Int, x - (realWidth * jx + sprite.offsetX) * sx), floor(Int, y - (realHeight * jy + sprite.offsetY) * sy)
    drawX += sx < 0 ? width * sx : 0
    drawY += sy < 0 ? height * sy : 0

    return Rectangle(drawX, drawY, sprite.width * abs(sx), sprite.height * abs(sy))
end

function getEntityRectangle(entity::Maple.Entity)
    x, y = position(entity)

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))

    return Rectangle(x, y, width, height)
end