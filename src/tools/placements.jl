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
    if layer.name == "entities" || layer.name == "triggers"
        return Main.generateEntity(Main.loadedState.map, Main.loadedState.room, material, x, y, nx, ny)

    elseif layer.name == "fgDecals" || layer.name == "bgDecals"
        texture = splitext(material)[1] * ".png"
        return Main.Maple.Decal(texture, x, y, sx, sy)
    end
end

function pushPreview!(layer::Main.Layer, room::Main.Maple.Room, preview::Any)
    if Main.layerName(layer) == "entities"
        push!(room.entities, preview)

    elseif Main.layerName(layer) == "triggers"
        push!(room.triggers, preview)

    elseif Main.layerName(layer) == "fgDecals"
        push!(room.fgDecals, preview)

    elseif Main.layerName(layer) == "bgDecals"
        push!(room.bgDecals, preview)
    end
end

function updateMaterialsEntities!(materials::Main.ListContainer)
    selectables = collect(keys(Main.entityPlacements))
    sort!(selectables)

    wantedEntity = get(Main.persistence, "placements_placements_entity", selectables[1])
    Main.updateTreeView!(materials, selectables, row -> row[1] == wantedEntity)
end

function updateMaterialsTriggers!(materials::Main.ListContainer)
    selectables = collect(keys(Main.triggerPlacements))
    sort!(selectables)

    wantedTrigger = get(Main.persistence, "placements_placements_trigger", selectables[1])
    Main.updateTreeView!(materials, selectables, row -> row[1] == wantedTrigger)
end

function updateMaterialsDecals!(materials::Main.ListContainer)
    Main.loadExternalSprites!()
    textures = Main.spritesToDecalTextures(Main.sprites)
    sort!(textures)
    filter!(filterAnimations, textures)

    wantedDecal = get(Main.persistence, "placements_placements_decal", textures[1])
    Main.updateTreeView!(materials, textures, row -> row[1] == wantedDecal)
end

function cleanup()
    global previewGhost = nothing
    global selectionRect = nothing

    Main.redrawLayer!(toolsLayer)
end

function toolSelected(subTools::Main.ListContainer, layers::Main.ListContainer, materials::Main.ListContainer)
    wantedLayer = get(Main.persistence, "placements_layer", "entities")
    Main.updateLayerList!(["entities", "triggers", "fgDecals", "bgDecals"], row -> row[1] == wantedLayer)
    Main.updateTreeView!(subTools, [])

    Main.redrawingFuncs["tools"] = drawSelection
    Main.redrawLayer!(toolsLayer)
end

function layerSelected(list::Main.ListContainer, materials::Main.ListContainer, selected::String)
    global targetLayer = Main.getLayerByName(drawingLayers, selected)
    if selected == "entities"
        updateMaterialsEntities!(materials)
        global previewGhost = nothing

    elseif selected == "triggers"
        updateMaterialsTriggers!(materials)
        global previewGhost = nothing

    elseif selected == "fgDecals" || selected == "bgDecals"
        updateMaterialsDecals!(materials)
        global previewGhost = nothing
    end

    Main.persistence["placements_layer"] = selected
end

function subToolSelected(list::Main.ListContainer, selected::String)
    
end

function materialSelected(list::Main.ListContainer, selected::String)
    if Main.layerName(targetLayer) == "entities"
        global material = Main.entityPlacements[selected]
        Main.persistence["placements_placements_entity"] = selected

    elseif Main.layerName(targetLayer) == "triggers"
        global material = Main.triggerPlacements[selected]
        Main.persistence["placements_placements_trigger"] = selected

    elseif Main.layerName(targetLayer) == "fgDecals" || Main.layerName(targetLayer) == "bgDecals" 
        global material = selected
        Main.persistence["placements_placements_decal"] = selected
    end
end

function mouseMotion(x::Number, y::Number)
    if !Main.modifierControl()
        newGhost = generatePreview(targetLayer, material, x * 8 - 8, y * 8 - 8, sx=scaleX, sy=scaleY)

        if selectionRect === nothing && newGhost != previewGhost
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
            Main.redrawLayer!(targetLayer)
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

function selectionMotionAbs(x1::Number, y1::Number, x2::Number, y2::Number)
    if Main.layerName(targetLayer) == "entities" || Main.layerName(targetLayer) == "triggers"
        if !Main.modifierControl()
            x1, y1, x2, y2 = floor.(Int, [x1, y1, x2 + 8 * sign(x2 - x1), y2 + 8 * sign(y2 - y1)] ./ 8) .* 8
        end

        newGhost = generatePreview(targetLayer, material, x1, y1, nx=x2, ny=y2)

        if newGhost != previewGhost
            global previewGhost = newGhost

            Main.redrawLayer!(toolsLayer)
        end
    end

    global selectionRect = Main.selectionRectangle(x1, y1, x2, y2)
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
    # Vertical Mirror
    Int('v') => (-1, 1),

    # Horizontal Mirror
    Int('h') => (1, -1),
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