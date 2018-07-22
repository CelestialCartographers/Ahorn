module Placements

displayName = "Placements"
group = "Placements"

drawingLayers = Main.Layer[]

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

function drawSelection(layer::Main.Layer, room::Main.Room)
    ctx = Main.creategc(toolsLayer.surface)

    if selectionRect !== nothing && selectionRect.w > 0 && selectionRect.h > 0
        if isa(material, Main.EntityPlacement) && material.placement == "rectangle" 
            Main.drawRectangle(ctx, selectionRect, Main.colors.selection_selection_fc, Main.colors.selection_selection_bc)
        end
    end

    if previewGhost !== nothing
        if Main.layerName(targetLayer) == "entities"
            Main.renderEntity(ctx, toolsLayer, previewGhost, room, alpha=Main.colors.ghost_preplacement_alpha)
            Main.renderEntitySelection(ctx, toolsLayer, previewGhost, room, alpha=Main.colors.ghost_preplacement_alpha)

        elseif Main.layerName(targetLayer) == "triggers"
            Main.renderTrigger(ctx, toolsLayer, previewGhost, room, alpha=Main.colors.ghost_preplacement_alpha)

        elseif Main.layerName(targetLayer) == "fgDecals" || Main.layerName(targetLayer) == "bgDecals"
            Main.drawDecal(ctx, previewGhost, alpha=Main.colors.ghost_preplacement_alpha)
        end
    end
end

function generatePreview(layer::Main.Layer, material::Any, x::Integer, y::Integer; sx::Integer=1, sy::Integer=1, nx=x + 8, ny=y + 8)
    if material !== nothing
        if layer.name == "entities" || layer.name == "triggers"
            return Main.generateEntity(Main.loadedState.map, Main.loadedState.room, material, x, y, nx, ny)

        elseif layer.name == "fgDecals" || layer.name == "bgDecals"
            texture = splitext(material)[1] * ".png"
            return Main.Maple.Decal(texture, x, y, sx, sy)
        end
    end
end

function pushPreview!(layer::Main.Layer, room::Main.Maple.Room, preview::Any)
    name = Main.layerName(layer)
    Main.History.addSnapshot!(Main.History.RoomSnapshot("Placement ($name)", room))

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
    selectables = collect(keys(Main.entityPlacements))
    sort!(selectables)

    wantedEntity = get(Main.persistence, "placements_placements_entity", selectables[1])
    Main.setMaterialList!(selectables, row -> row[1] == wantedEntity)
end

function updateMaterialsTriggers!()
    selectables = collect(keys(Main.triggerPlacements))
    sort!(selectables)

    wantedTrigger = get(Main.persistence, "placements_placements_trigger", selectables[1])
    Main.setMaterialList!(selectables, row -> row[1] == wantedTrigger)
end

function updateMaterialsDecals!()
    Main.loadExternalSprites!()
    textures = Main.spritesToDecalTextures(Main.sprites)
    sort!(textures)
    filter!(filterAnimations, textures)

    wantedDecal = get(Main.persistence, "placements_placements_decal", textures[1])
    Main.setMaterialList!(textures, row -> row[1] == wantedDecal)
end

function cleanup()
    global previewGhost = nothing
    global selectionRect = nothing

    Main.redrawLayer!(toolsLayer)
end

function toolSelected(subTools::Main.ListContainer, layers::Main.ListContainer, materials::Main.ListContainer)
    wantedLayer = get(Main.persistence, "placements_layer", "entities")
    Main.updateLayerList!(placementLayers, row -> row[1] == wantedLayer)
    Main.updateTreeView!(subTools, [])

    Main.redrawingFuncs["tools"] = drawSelection
    Main.redrawLayer!(toolsLayer)
end

function layerSelected(list::Main.ListContainer, materials::Main.ListContainer, selected::String)
    prevLayer = Main.layerName(targetLayer)
    global targetLayer = Main.getLayerByName(drawingLayers, selected)

    if selected == "entities"
        updateMaterialsEntities!()

    elseif selected == "triggers"
        updateMaterialsTriggers!()

    elseif (selected == "fgDecals" || selected == "bgDecals") && prevLayer != "fgDecals" && prevLayer != "bgDecals" || isempty(materials.data)
        updateMaterialsDecals!()
    end

    global previewGhost = nothing

    Main.persistence["placements_layer"] = selected
end

function subToolSelected(list::Main.ListContainer, selected::String)
    
end

function materialSelected(list::Main.ListContainer, selected::String)
    if Main.layerName(targetLayer) == "entities"
        if haskey(Main.entityPlacements, selected)
            global material = Main.entityPlacements[selected]
            Main.persistence["placements_placements_entity"] = selected
        end

    elseif Main.layerName(targetLayer) == "triggers"
        if haskey(Main.triggerPlacements, selected)
            global material = Main.triggerPlacements[selected]
            Main.persistence["placements_placements_trigger"] = selected
        end

    elseif Main.layerName(targetLayer) == "fgDecals" || Main.layerName(targetLayer) == "bgDecals" 
        global material = selected
        Main.persistence["placements_placements_decal"] = selected
    end
end

function mouseMotion(x::Number, y::Number)
    if !Main.modifierControl()
        newGhost = generatePreview(targetLayer, material, x * 8 - 8, y * 8 - 8, sx=scaleX, sy=scaleY)

        if selectionRect === nothing && newGhost != previewGhost
            # No need to redraw if the target is on the same tile
            if isa(previewGhost, Main.Maple.Entity) || isa(previewGhost, Main.Maple.Trigger)
                if newGhost.data["x"] == previewGhost.data["x"] && newGhost.data["y"] == previewGhost.data["y"]
                    return false
                end
            end

            if isa(previewGhost, Main.Maple.Decal)
                if newGhost.x == previewGhost.x && newGhost.y == previewGhost.y
                    return false
                end
            end

            global previewGhost = newGhost

            Main.redrawLayer!(toolsLayer)
        end
    end
end

function mouseMotionAbs(x::Number, y::Number)
    if Main.modifierControl()
        newGhost = generatePreview(targetLayer, material, x, y, sx=scaleX, sy=scaleY)

        if selectionRect === nothing && newGhost != previewGhost
            global previewGhost = newGhost

            Main.redrawLayer!(toolsLayer)
        end
    end
end

function middleClickAbs(x::Number, y::Number)
    layerName = Main.layerName(targetLayer)
    selections = Main.getSelected(Main.loadedState.room, layerName, Main.Rectangle(x, y, 1, 1))
    best = Main.bestSelection(selections)

    if best !== nothing
        name, rect, target = best

        if name == "fgDecals" || name == "bgDecals"
            global material = Main.fixTexturePath(target.texture)
            Main.selectMaterialList!(material)
            Main.persistence["placements_placements_decal"] = material

        elseif name == "entities" || name == "triggers"
            func = name == "entities"? Main.Maple.Entity : Main.Maple.Trigger
            global material = Main.EntityPlacement(
                (x, y) -> func(target.name, x=x, y=y),
                "point",
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
        pushPreview!(targetLayer, Main.loadedState.room, previewGhost)

        Main.redrawLayer!(toolsLayer)
        Main.redrawLayer!(targetLayer)
    end
end

function rightClickAbs(x::Number, y::Number)
    Main.displayProperties(x, y, Main.loadedState.room, targetLayer)

    Main.redrawLayer!(toolsLayer)        
end

function selectionMotionAbs(x1::Number, y1::Number, x2::Number, y2::Number)
    if Main.layerName(targetLayer) == "entities" || Main.layerName(targetLayer) == "triggers"
        if material.placement == "line"
            if !Main.modifierControl()
                x1, y1, x2, y2 = floor.(Int, [x1, y1, x2 + 8 * sign(x2 - x1), y2 + 8 * sign(y2 - y1)] ./ 8) .* 8
            end

            newGhost = generatePreview(targetLayer, material, x1, y1, nx=x2, ny=y2)

            if newGhost != previewGhost
                global previewGhost = newGhost

                Main.redrawLayer!(toolsLayer)
            end
        end
    end
end

function selectionMotionAbs(rect::Main.Rectangle)
    if Main.modifierControl()
        if Main.layerName(targetLayer) == "entities" || Main.layerName(targetLayer) == "triggers"
            if material.placement == "rectangle"
                newGhost = generatePreview(targetLayer, material, rect.x, rect.y, nx=rect.x + rect.w, ny=rect.y + rect.h)

                if newGhost != previewGhost
                    global previewGhost = newGhost

                    Main.redrawLayer!(toolsLayer)
                end
            end
        end

        global selectionRect = rect
    end
end

function selectionMotion(rect::Main.Rectangle)
    if !Main.modifierControl()
        ax1, ay1, ax2, ay2 = rect.x * 8 - 8, rect.y * 8 - 8, (rect.x + rect.w) * 8 - 8, (rect.y + rect.h) * 8 - 8

        if Main.layerName(targetLayer) == "entities" || Main.layerName(targetLayer) == "triggers"
            if material.placement == "rectangle"
                newGhost = generatePreview(targetLayer, material, ax1, ay1, nx=ax2, ny=ay2)

                if newGhost != previewGhost
                    global previewGhost = newGhost

                    Main.redrawLayer!(toolsLayer)
                end
            end
        end

        global selectionRect = Main.Rectangle(ax1, ay1, rect.w * 8, rect.h * 8)
    end
end


# Doesn't matter if this is grid/abs, we only need to know the selection is done
function selectionFinish(rect::Main.Rectangle)
    if previewGhost !== nothing
        pushPreview!(targetLayer, Main.loadedState.room, previewGhost)
        global previewGhost = nothing
        global selectionRect = nothing

        Main.redrawLayer!(toolsLayer)
        Main.redrawLayer!(targetLayer)
    end
end

function layersChanged(layers::Array{Main.Layer, 1})
    wantedLayer = get(Main.persistence, "placements_layer", "entities")

    global drawingLayers = layers
    global toolsLayer = Main.getLayerByName(layers, "tools")
    global targetLayer = Main.selectLayer!(layers, wantedLayer, "entities")
end

scaleMultipliers = Dict{Integer, Tuple{Number, Number}}(
    # Vertical Flip
    Int('v') => (1, -1),

    # Horizontal Flip
    Int('h') => (-1, 1),
)

function keyboard(event::Main.eventKey)
    if haskey(scaleMultipliers, event.keyval)
        msx, msy = scaleMultipliers[event.keyval]
        
        global scaleX *= msx
        global scaleY *= msy
    end

    return true
end

end