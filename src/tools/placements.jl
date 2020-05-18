module Placements

using ..Ahorn, Maple

displayName = "Placements"
group = "Placements"

drawingLayers = Ahorn.Layer[]

toolsLayer = nothing
targetLayer = nothing

material = nothing
materialName = nothing

scaleX = 1
scaleY = 1

selectionRect = nothing
previewGhost = nothing
clonedEntity = nothing

blacklistedCloneAttrs = ["id", "x", "y"]

placementLayers = String["entities", "triggers", "fgDecals", "bgDecals"]

function drawPlacements(layer::Ahorn.Layer, room::Ahorn.DrawableRoom, camera::Ahorn.Camera)
    ctx = Ahorn.getSurfaceContext(toolsLayer.surface)

    if selectionRect !== nothing && selectionRect.w > 0 && selectionRect.h > 0
        if isa(material, Ahorn.EntityPlacement) && material.placement == "rectangle" 
            Ahorn.drawRectangle(ctx, selectionRect, Ahorn.colors.selection_selection_fc, Ahorn.colors.selection_selection_bc)
        end
    end

    if previewGhost !== nothing
        if Ahorn.layerName(targetLayer) == "entities"
            Ahorn.renderEntity(ctx, toolsLayer, previewGhost, room.room, alpha=Ahorn.colors.ghost_preplacement_alpha)
            Ahorn.renderEntitySelection(ctx, toolsLayer, previewGhost, room.room, alpha=Ahorn.colors.ghost_preplacement_alpha)

        elseif Ahorn.layerName(targetLayer) == "triggers"
            Ahorn.renderTrigger(ctx, toolsLayer, previewGhost, room.room, alpha=Ahorn.colors.ghost_preplacement_alpha)
            Ahorn.renderTriggerSelection(ctx, toolsLayer, previewGhost, room.room, alpha=Ahorn.colors.ghost_preplacement_alpha)

        elseif Ahorn.layerName(targetLayer) == "fgDecals" || Ahorn.layerName(targetLayer) == "bgDecals"
            Ahorn.drawDecal(ctx, previewGhost, alpha=Ahorn.colors.ghost_preplacement_alpha)
        end
    end
end

function generatePreview!(layer::Ahorn.Layer, material::Any, x, y; sx=1, sy=1, nx=x + 8, ny=y)
    if material !== nothing
        if layer.name == "entities" || layer.name == "triggers"
            # Use cache if possible, otherwise create a new entity/trigger

            placementsCache = layer.name == "entities" ? Ahorn.entityPlacementsCache : Ahorn.triggerPlacementsCache
            placements = layer.name == "entities" ? Ahorn.entityPlacements : Ahorn.triggerPlacements

            if materialName !== nothing
                return Ahorn.updateCachedEntityPosition!(placementsCache, placements, Ahorn.loadedState.map, Ahorn.loadedState.room, materialName, x, y, nx, ny)

            else
                if clonedEntity === nothing
                    global clonedEntity = Ahorn.generateEntity(Ahorn.loadedState.map, Ahorn.loadedState.room, material, x, y, nx, ny)
                end

                return Ahorn.updateEntityPosition!(clonedEntity, material, Ahorn.loadedState.map, Ahorn.loadedState.room, x, y, nx, ny)
            end

        elseif layer.name == "fgDecals" || layer.name == "bgDecals"
            texture = splitext(material)[1] * ".png"

            return Maple.Decal(texture, x, y, sx, sy)
        end
    end
end

function pushPreview!(layer::Ahorn.Layer, room::Maple.Room, preview::Any)
    if !get(Ahorn.config, "allow_out_of_bounds_placement", false)
        width, height = room.size
        x, y = Ahorn.position(preview)

        if x < 0 || x > width || y < 0 || y > height
            return false
        end
    end 

    name = Ahorn.layerName(layer)

    # Update the id when we place the entity/trigger
    if name == "entities" || name == "triggers"
        preview.id = Ahorn.EntityIds.nextId()
    end

    # Make sure we don't have the same referance,
    # as the preview can be placed multiple times
    preview = deepcopy(preview)
    target = Ahorn.selectionTargets[name](room)

    Ahorn.History.addSnapshot!(Ahorn.History.RoomSnapshot("Placement ($name)", room))
    push!(target, preview)

    return true
end

function updateMaterialsEntities!()
    selectables = collect(keys(Ahorn.entityPlacements))
    sort!(selectables)

    if !isa(clonedEntity, Maple.Entity)
        wantedEntity = get(Ahorn.persistence, "placements_placements_entity", selectables[1])
        Ahorn.setMaterialList!(selectables, row -> row[1] == wantedEntity)
    end
end

function updateMaterialsTriggers!()
    selectables = collect(keys(Ahorn.triggerPlacements))
    sort!(selectables)

    if !isa(clonedEntity, Maple.Trigger)
        wantedTrigger = get(Ahorn.persistence, "placements_placements_trigger", selectables[1])
        Ahorn.setMaterialList!(selectables, row -> row[1] == wantedTrigger)
    end
end

function updateMaterialsDecals!()
    textures = Ahorn.decalTextures()

    wantedDecal = get(Ahorn.persistence, "placements_placements_decal", textures[1])
    Ahorn.setMaterialList!(textures, row -> row[1] == wantedDecal)
end

function cleanup()
    global previewGhost = nothing
    global selectionRect = nothing

    Ahorn.redrawLayer!(toolsLayer)
end

function toolSelected(subTools::Ahorn.ListContainer, layers::Ahorn.ListContainer, materials::Ahorn.ListContainer)
    wantedLayer = get(Ahorn.persistence, "placements_layer", "entities")
    Ahorn.updateLayerList!(placementLayers, row -> row[1] == wantedLayer)
    Ahorn.updateTreeView!(subTools, [])

    Ahorn.redrawingFuncs["tools"] = drawPlacements
    Ahorn.redrawLayer!(toolsLayer)
end

function layerSelected(list::Ahorn.ListContainer, materials::Ahorn.ListContainer, selected::String)
    prevLayer = Ahorn.layerName(targetLayer)
    global targetLayer = Ahorn.getLayerByName(drawingLayers, selected)

    if selected == "entities"
        updateMaterialsEntities!()

    elseif selected == "triggers"
        updateMaterialsTriggers!()

    elseif (selected == "fgDecals" || selected == "bgDecals") && prevLayer != "fgDecals" && prevLayer != "bgDecals" || isempty(materials.data)
        updateMaterialsDecals!()
    end

    global previewGhost = nothing

    Ahorn.persistence["placements_layer"] = selected
end

function subToolSelected(list::Ahorn.ListContainer, selected::String)
    
end

function materialSelected(list::Ahorn.ListContainer, selected::String)
    global materialName = selected
    layerName = Ahorn.layerName(targetLayer)

    if layerName == "entities"
        if haskey(Ahorn.entityPlacements, selected)
            global clonedEntity = nothing
            global material = Ahorn.entityPlacements[selected]
            Ahorn.persistence["placements_placements_entity"] = selected
        end

    elseif layerName == "triggers"
        if haskey(Ahorn.triggerPlacements, selected)
            global clonedEntity = nothing
            global material = Ahorn.triggerPlacements[selected]
            Ahorn.persistence["placements_placements_trigger"] = selected
        end

    elseif layerName == "fgDecals" || layerName == "bgDecals" 
        global material = selected
        Ahorn.persistence["placements_placements_decal"] = selected
    end
end

function materialFiltered(list::Ahorn.ListContainer)
    layerName = Ahorn.layerName(targetLayer)

    if layerName == "entities" && isa(clonedEntity, Maple.Entity)
        return true
    end

    if layerName == "triggers" && isa(clonedEntity, Maple.Trigger)
        return true
    end

    Ahorn.selectRow!(list, row -> row[1] == materialName)
end

function updatePreviewGhost(x::Number, y::Number)
    targetX, targetY = x, y

    if !Ahorn.modifierControl()
        targetX = x * 8 - 8
        targetY = y * 8 - 8
    end

    prevGhost = deepcopy(previewGhost)
    newGhost = generatePreview!(targetLayer, material, targetX, targetY, sx=scaleX, sy=scaleY)

    if newGhost != prevGhost
        # No need to redraw if the target is on the same tile
        if isa(prevGhost, Maple.Entity) || isa(prevGhost, Maple.Trigger)
            if newGhost.data["x"] == prevGhost.data["x"] && newGhost.data["y"] == prevGhost.data["y"]
                return false
            end
        end

        if isa(prevGhost, Maple.Decal)
            if newGhost.x == prevGhost.x && newGhost.y == prevGhost.y
                return false
            end
        end

        global previewGhost = newGhost
        Ahorn.redrawLayer!(toolsLayer)

        return true
    end
end

function mouseMotion(x::Number, y::Number)
    if !Ahorn.modifierControl() && selectionRect === nothing
        updatePreviewGhost(x, y)
    end
end

function mouseMotionAbs(x::Number, y::Number)
    if Ahorn.modifierControl() && selectionRect === nothing
        updatePreviewGhost(x, y)
    end
end

function placementFunc(target::Union{Maple.Entity, Maple.Trigger})
    constructor = isa(target, Maple.Entity) ? Maple.Entity : Maple.Trigger

    return (x::Number, y::Number) -> constructor(target.name, x=x, y=y)
end

function middleClickAbs(x::Number, y::Number)
    layerName = Ahorn.layerName(targetLayer)
    selections = Ahorn.getSelected(Ahorn.loadedState.room, layerName, Ahorn.Rectangle(x, y, 1, 1))
    best = Ahorn.bestSelection(selections)

    if best !== nothing
        name, rect, target = best.layerName, best.rectangle, best.target

        if name == "fgDecals" || name == "bgDecals"
            global material = Ahorn.fixTexturePath(target.texture)
            Ahorn.selectMaterialList!(material)
            Ahorn.persistence["placements_placements_decal"] = material

        elseif name == "entities" || name == "triggers"
            horizontal, vertical = Ahorn.canResizeWrapper(target)
            placementType = horizontal || vertical ? "rectangle" : "point"

            # Fake a entity/trigger of the target
            # Copy all allowed attributes and store a fake (x, y) position for offseting nodes properly
            # If the entity/trigger is resizeable use "rectangle" placement rather than "point"

            global materialName = nothing
            global material = Ahorn.EntityPlacement(
                placementFunc(target),
                placementType,
                merge(
                    Dict{String, Any}((k, v) for (k, v) in deepcopy(target.data) if !(k in blacklistedCloneAttrs)),
                    Dict{String, Any}("__x" => target.data["x"], "__y" => target.data["y"])
                ),
                function(entity::Union{Maple.Entity, Maple.Trigger})
                    nodes = get(entity.data, "nodes", Tuple{Integer, Integer}[])
                    if length(nodes) > 0
                        x, y = entity.data["x"], entity.data["y"]
                        origx, origy = entity.data["__x"], entity.data["__y"]
                        newNodes = Tuple{Integer, Integer}[]

                        for node in nodes
                            nx, ny = node
                            push!(newNodes, (x + nx - origx, y + ny - origy))
                        end 

                        entity.data["nodes"] = newNodes
                    end

                    delete!(entity.data, "__x")
                    delete!(entity.data, "__y")
                end
            )

            global clonedEntity = nothing
            updatePreviewGhost(x, y)
        end

        Ahorn.redrawLayer!(toolsLayer)
    end
end

function leftClick(x::Number, y::Number)
    if previewGhost !== nothing
        pushPreview!(targetLayer, Ahorn.loadedState.room, previewGhost)

        Ahorn.redrawLayer!(toolsLayer)
        Ahorn.redrawLayer!(targetLayer)
    end
end

function rightClickAbs(x::Number, y::Number)
    Ahorn.displayProperties(x, y, Ahorn.loadedState.room, targetLayer, toolsLayer)

    Ahorn.redrawLayer!(toolsLayer)        
end

function selectionMotionAbs(x1::Number, y1::Number, x2::Number, y2::Number)
    if Ahorn.layerName(targetLayer) == "entities" || Ahorn.layerName(targetLayer) == "triggers"
        if material.placement == "line"
            if !Ahorn.modifierControl()
                x1, y1, x2, y2 = floor.(Int, [x1, y1, x2 + 8 * sign(x2 - x1), y2 + 8 * sign(y2 - y1)] ./ 8) .* 8
            end

            prevGhost = deepcopy(previewGhost)
            newGhost = generatePreview!(targetLayer, material, x1, y1, nx=x2, ny=y2)

            if newGhost != prevGhost
                global previewGhost = newGhost

                Ahorn.redrawLayer!(toolsLayer)
            end
        end
    end
end

function selectionMotionAbs(rect::Ahorn.Rectangle)
    if Ahorn.modifierControl()
        global selectionRect = rect

        if Ahorn.layerName(targetLayer) == "entities" || Ahorn.layerName(targetLayer) == "triggers"
            if material.placement == "rectangle"
                prevGhost = deepcopy(previewGhost)
                newGhost = generatePreview!(targetLayer, material, rect.x, rect.y, nx=rect.x + rect.w, ny=rect.y + rect.h)

                if newGhost != prevGhost
                    global previewGhost = newGhost

                    Ahorn.redrawLayer!(toolsLayer)
                end
            end
        end
    end
end

function selectionMotion(rect::Ahorn.Rectangle)
    if !Ahorn.modifierControl()
        ax1, ay1, ax2, ay2 = rect.x * 8 - 8, rect.y * 8 - 8, (rect.x + rect.w) * 8 - 8, (rect.y + rect.h) * 8 - 8

        global selectionRect = Ahorn.Rectangle(ax1, ay1, rect.w * 8, rect.h * 8)

        if Ahorn.layerName(targetLayer) == "entities" || Ahorn.layerName(targetLayer) == "triggers"
            if material.placement == "rectangle"
                prevGhost = deepcopy(previewGhost)
                newGhost = generatePreview!(targetLayer, material, ax1, ay1, nx=ax2, ny=ay2)

                if newGhost != prevGhost
                    global previewGhost = newGhost

                    Ahorn.redrawLayer!(toolsLayer)
                end
            end
        end
    end
end


# Doesn't matter if this is grid/abs, we only need to know the selection is done
function selectionFinish(rect::Ahorn.Rectangle)
    if previewGhost !== nothing
        pushPreview!(targetLayer, Ahorn.loadedState.room, previewGhost)

        global previewGhost = nothing
        global selectionRect = nothing

        Ahorn.redrawLayer!(toolsLayer)
        Ahorn.redrawLayer!(targetLayer)
    end
end

function layersChanged(layers::Array{Ahorn.Layer, 1})
    wantedLayer = get(Ahorn.persistence, "placements_layer", "entities")

    global drawingLayers = layers
    global toolsLayer = Ahorn.getLayerByName(layers, "tools")
    global targetLayer = Ahorn.selectLayer!(layers, wantedLayer, "entities")
end

decalScaleVals = (1.0, 2.0^4)

resizeModifiers = Dict{Integer, Tuple{Number, Number}}(
    # w, h
    # Decrease / Increase width
    Int('q') => (1, 0),
    Int('e') => (-1, 0),

    # Decrease / Increase height
    Int('a') => (0, 1),
    Int('d') => (0, -1)
)

scaleMultipliers = Dict{Integer, Tuple{Number, Number}}(
    # Vertical Flip
    Int('v') => (1, -1),

    # Horizontal Flip
    Int('h') => (-1, 1),
)

function keyboard(event::Ahorn.eventKey)
    redraw = false

    if haskey(scaleMultipliers, event.keyval)
        msx, msy = scaleMultipliers[event.keyval]
        
        global scaleX *= msx
        global scaleY *= msy

        redraw = true
    end

    if haskey(resizeModifiers, event.keyval)
        extraW, extraH = resizeModifiers[event.keyval]
        minVal, maxVal = decalScaleVals
        
        global scaleX = floor(Int, sign(scaleX) * clamp(abs(scaleX) * 2.0^extraW, minVal, maxVal))
        global scaleY = floor(Int, sign(scaleY) * clamp(abs(scaleY) * 2.0^extraH, minVal, maxVal))

        redraw = true
    end

    if redraw
        name = Ahorn.layerName(targetLayer)

        if name == "fgDecals" || name == "bgDecals"
            global previewGhost = generatePreview!(targetLayer, material, previewGhost.x, previewGhost.y, sx=scaleX, sy=scaleY)

            Ahorn.redrawLayer!(toolsLayer)
        end
    end

    return true
end

end