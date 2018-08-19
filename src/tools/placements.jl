module Placements

using ..Ahorn

displayName = "Placements"
group = "Placements"

drawingLayers = Ahorn.Layer[]

toolsLayer = nothing
targetLayer = nothing

material = nothing

scaleX = 1
scaleY = 1

selectionRect = nothing
previewGhost = nothing

blacklistedCloneAttrs = ["id", "x", "y"]

animationRegex = r"\D+0*?$"
filterAnimations(s::String) = ismatch(animationRegex, s)

placementLayers = String["entities", "triggers", "fgDecals", "bgDecals"]

function drawPlacements(layer::Ahorn.Layer, room::Ahorn.Room)
    ctx = Ahorn.creategc(toolsLayer.surface)

    if selectionRect !== nothing && selectionRect.w > 0 && selectionRect.h > 0
        if isa(material, Ahorn.EntityPlacement) && material.placement == "rectangle" 
            Ahorn.drawRectangle(ctx, selectionRect, Ahorn.colors.selection_selection_fc, Ahorn.colors.selection_selection_bc)
        end
    end

    if previewGhost !== nothing
        if Ahorn.layerName(targetLayer) == "entities"
            Ahorn.renderEntity(ctx, toolsLayer, previewGhost, room, alpha=Ahorn.colors.ghost_preplacement_alpha)
            Ahorn.renderEntitySelection(ctx, toolsLayer, previewGhost, room, alpha=Ahorn.colors.ghost_preplacement_alpha)

        elseif Ahorn.layerName(targetLayer) == "triggers"
            Ahorn.renderTrigger(ctx, toolsLayer, previewGhost, room, alpha=Ahorn.colors.ghost_preplacement_alpha)
            Ahorn.renderTriggerSelection(ctx, toolsLayer, previewGhost, room, alpha=Ahorn.colors.ghost_preplacement_alpha)

        elseif Ahorn.layerName(targetLayer) == "fgDecals" || Ahorn.layerName(targetLayer) == "bgDecals"
            Ahorn.drawDecal(ctx, previewGhost, alpha=Ahorn.colors.ghost_preplacement_alpha)
        end
    end
end

function generatePreview(layer::Ahorn.Layer, material::Any, x::Integer, y::Integer; sx::Integer=1, sy::Integer=1, nx=x + 8, ny=y + 8)
    if material !== nothing
        if layer.name == "entities" || layer.name == "triggers"
            return Ahorn.generateEntity(Ahorn.loadedState.map, Ahorn.loadedState.room, material, x, y, nx, ny)

        elseif layer.name == "fgDecals" || layer.name == "bgDecals"
            texture = splitext(material)[1] * ".png"
            return Ahorn.Maple.Decal(texture, x, y, sx, sy)
        end
    end
end

function pushPreview!(layer::Ahorn.Layer, room::Ahorn.Maple.Room, preview::Any)
    name = Ahorn.layerName(layer)
    Ahorn.History.addSnapshot!(Ahorn.History.RoomSnapshot("Placement ($name)", room))

    # Make sure we don't have the same referance,
    # as the preview can be placed multiple times
    preview = deepcopy(preview)

    if name == "entities"
        push!(room.entities, preview)

    elseif name == "triggers"
        push!(room.triggers, preview)

    elseif name == "fgDecals"
        push!(room.fgDecals, preview)

    elseif name == "bgDecals"
        push!(room.bgDecals, preview)
    end
end

function updateMaterialsEntities!()
    selectables = collect(keys(Ahorn.entityPlacements))
    sort!(selectables)

    wantedEntity = get(Ahorn.persistence, "placements_placements_entity", selectables[1])
    Ahorn.setMaterialList!(selectables, row -> row[1] == wantedEntity)
end

function updateMaterialsTriggers!()
    selectables = collect(keys(Ahorn.triggerPlacements))
    sort!(selectables)

    wantedTrigger = get(Ahorn.persistence, "placements_placements_trigger", selectables[1])
    Ahorn.setMaterialList!(selectables, row -> row[1] == wantedTrigger)
end

function updateMaterialsDecals!()
    Ahorn.loadExternalSprites!()
    textures = Ahorn.spritesToDecalTextures(Ahorn.sprites)
    sort!(textures)
    filter!(filterAnimations, textures)

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
    if Ahorn.layerName(targetLayer) == "entities"
        if haskey(Ahorn.entityPlacements, selected)
            global material = Ahorn.entityPlacements[selected]
            Ahorn.persistence["placements_placements_entity"] = selected
        end

    elseif Ahorn.layerName(targetLayer) == "triggers"
        if haskey(Ahorn.triggerPlacements, selected)
            global material = Ahorn.triggerPlacements[selected]
            Ahorn.persistence["placements_placements_trigger"] = selected
        end

    elseif Ahorn.layerName(targetLayer) == "fgDecals" || Ahorn.layerName(targetLayer) == "bgDecals" 
        global material = selected
        Ahorn.persistence["placements_placements_decal"] = selected
    end
end

function mouseMotion(x::Number, y::Number)
    if !Ahorn.modifierControl()
        newGhost = generatePreview(targetLayer, material, x * 8 - 8, y * 8 - 8, sx=scaleX, sy=scaleY)

        if selectionRect === nothing && newGhost != previewGhost
            # No need to redraw if the target is on the same tile
            if isa(previewGhost, Ahorn.Maple.Entity) || isa(previewGhost, Ahorn.Maple.Trigger)
                if newGhost.data["x"] == previewGhost.data["x"] && newGhost.data["y"] == previewGhost.data["y"]
                    return false
                end
            end

            if isa(previewGhost, Ahorn.Maple.Decal)
                if newGhost.x == previewGhost.x && newGhost.y == previewGhost.y
                    return false
                end
            end

            global previewGhost = newGhost

            Ahorn.redrawLayer!(toolsLayer)
        end
    end
end

function mouseMotionAbs(x::Number, y::Number)
    if Ahorn.modifierControl()
        newGhost = generatePreview(targetLayer, material, x, y, sx=scaleX, sy=scaleY)

        if selectionRect === nothing && newGhost != previewGhost
            global previewGhost = newGhost

            Ahorn.redrawLayer!(toolsLayer)
        end
    end
end

function middleClickAbs(x::Number, y::Number)
    layerName = Ahorn.layerName(targetLayer)
    selections = Ahorn.getSelected(Ahorn.loadedState.room, layerName, Ahorn.Rectangle(x, y, 1, 1))
    best = Ahorn.bestSelection(selections)

    if best !== nothing
        name, rect, target = best

        if name == "fgDecals" || name == "bgDecals"
            global material = Ahorn.fixTexturePath(target.texture)
            Ahorn.selectMaterialList!(material)
            Ahorn.persistence["placements_placements_decal"] = material

        elseif name == "entities" || name == "triggers"
            func = name == "entities"? Ahorn.Maple.Entity : Ahorn.Maple.Trigger
            horizontal, vertical = Ahorn.canResize(target)

            placementType = horizontal || vertical? "rectangle" : "point"

            # Fake a entity/trigger of the target
            # Copy all allowed attributes and store a fake (x, y) position for offseting nodes properly
            # If the entity/trigger is resizeable use "rectangle" placement rather than "point"

            global material = Ahorn.EntityPlacement(
                (x, y) -> func(target.name, x=x, y=y),
                placementType,
                merge(
                    Dict{String, Any}((k, v) for (k, v) in deepcopy(target.data) if !(k in blacklistedCloneAttrs)),
                    Dict{String, Any}("__x" => target.data["x"], "__y" => target.data["y"])
                ),
                function(entity) 
                    nodes = get(entity.data, "nodes", [])
                    if length(nodes) > 0
                        x, y = entity.data["x"], entity.data["y"]
                        origx, origy = entity.data["__x"], entity.data["__y"]
                        newNodes = Tuple{Integer, Integer}[]

                        for node in nodes
                            nx, ny = node
                            push!(newNodes, (x + nx - origx, y + ny - origy))
                        end 

                        entity.data["nodes"] = newNodes

                        delete!(entity.data, "__x")
                        delete!(entity.data, "__y")
                    end
                end
            )
        end
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

            newGhost = generatePreview(targetLayer, material, x1, y1, nx=x2, ny=y2)

            if newGhost != previewGhost
                global previewGhost = newGhost

                Ahorn.redrawLayer!(toolsLayer)
            end
        end
    end
end

function selectionMotionAbs(rect::Ahorn.Rectangle)
    if Ahorn.modifierControl()
        if Ahorn.layerName(targetLayer) == "entities" || Ahorn.layerName(targetLayer) == "triggers"
            if material.placement == "rectangle"
                newGhost = generatePreview(targetLayer, material, rect.x, rect.y, nx=rect.x + rect.w, ny=rect.y + rect.h)

                if newGhost != previewGhost
                    global previewGhost = newGhost

                    Ahorn.redrawLayer!(toolsLayer)
                end
            end
        end

        global selectionRect = rect
    end
end

function selectionMotion(rect::Ahorn.Rectangle)
    if !Ahorn.modifierControl()
        ax1, ay1, ax2, ay2 = rect.x * 8 - 8, rect.y * 8 - 8, (rect.x + rect.w) * 8 - 8, (rect.y + rect.h) * 8 - 8

        if Ahorn.layerName(targetLayer) == "entities" || Ahorn.layerName(targetLayer) == "triggers"
            if material.placement == "rectangle"
                newGhost = generatePreview(targetLayer, material, ax1, ay1, nx=ax2, ny=ay2)

                if newGhost != previewGhost
                    global previewGhost = newGhost

                    Ahorn.redrawLayer!(toolsLayer)
                end
            end
        end

        global selectionRect = Ahorn.Rectangle(ax1, ay1, rect.w * 8, rect.h * 8)
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

scaleMultipliers = Dict{Integer, Tuple{Number, Number}}(
    # Vertical Flip
    Int('v') => (1, -1),

    # Horizontal Flip
    Int('h') => (-1, 1),
)

function keyboard(event::Ahorn.eventKey)
    if haskey(scaleMultipliers, event.keyval)
        msx, msy = scaleMultipliers[event.keyval]
        
        global scaleX *= msx
        global scaleY *= msy
    end

    return true
end

end