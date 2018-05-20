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
        Main.drawRectangle(ctx, selectionRect, Main.colors.selection_selection_fc, Main.colors.selection_selection_bc)
    end

    if previewGhost != nothing
        if Main.layerName(targetLayer) == "entities"
            Main.Cairo.save(ctx)

            Main.renderEntity(ctx, toolsLayer, previewGhost, room, alpha=Main.colors.entity_preplacement_alpha)
            Main.renderEntitySelection(ctx, toolsLayer, previewGhost, room, alpha=Main.colors.entity_preplacement_alpha)

            Main.restore(ctx)

        elseif Main.layerName(targetLayer) == "fgDecals" || Main.layerName(targetLayer) == "bgDecals"
            Main.Cairo.save(ctx)

            Main.drawDecal(ctx, previewGhost, alpha=Main.colors.entity_preplacement_alpha)
    
            Main.restore(ctx)
        end
    end
end

function generatePreview(layer::Main.Layer, material::Any, x::Integer, y::Integer; sx::Integer=1, sy::Integer=1, width=8, height=8)
    if layer.name == "entities"
        return Main.generateEntity(material, x, y, width, height)

    elseif layer.name == "fgDecals" || layer.name == "bgDecals"
        texture = splitext(material)[1] * ".png"
        return Main.Maple.Decal(texture, x, y, sx, sy)
    end
end

function pushPreview!(layer::Main.Layer, room::Main.Maple.Room, preview::Any)
    if Main.layerName(layer) == "entities"
        push!(room.entities, preview)

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

function updateMaterialsDecals!(materials::Main.ListContainer)
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
    Main.updateTreeView!(layers, ["entities", "fgDecals", "bgDecals"], row -> row[1] == wantedLayer)
    Main.updateTreeView!(subTools, [])

    Main.redrawingFuncs["tools"] = drawSelection
    Main.redrawLayer!(toolsLayer)
end

function layerSelected(list::Main.ListContainer, materials::Main.ListContainer, selected::String)
    global targetLayer = Main.getLayerByName(drawingLayers, selected)
    if selected == "entities"
        updateMaterialsEntities!(materials)
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
    selections = Main.getSelected(Main.loadedRoom, layerName, Main.Rectangle(x, y, 1, 1))
    best = Main.smallestSelection(selections)

    if best !== nothing
        name, rect, target = best

        if name == "fgDecals" || name == "bgDecals"
            global material = target.texture
            Main.selectMaterialList!(material)
            Main.persistence["placements_placements_decal"] = material

        elseif name == "entities"
            global material = Main.EntityPlacement(
                (x, y) -> Main.Maple.Entity(target.name, x=x, y=y),
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
        pushPreview!(targetLayer, Main.loadedRoom, previewGhost)

        Main.redrawLayer!(toolsLayer)
        Main.redrawLayer!(targetLayer)
    end
end

function selectionMotion(rect::Main.Rectangle)
    x, y = rect.x, rect.y
    w, h = rect.w * 8, rect.h * 8

    if !Main.modifierControl() && Main.layerName(targetLayer) == "entities"
        newGhost = generatePreview(targetLayer, material, x * 8 - 8, y * 8 - 8, width=w, height=h)

        if newGhost != previewGhost
            global previewGhost = newGhost

            Main.redrawLayer!(toolsLayer)
        end
    end
end

function selectionMotionAbs(rect::Main.Rectangle)
    x, y = rect.x, rect.y
    w, h = rect.w, rect.h

    redrawTools = false

    if rect != selectionRect
        global selectionRect = rect
        redrawTools = true
    end

    if Main.modifierControl() && Main.layerName(targetLayer) == "entities"
        newGhost = generatePreview(targetLayer, material, x, y, width=w, height=h)

        if newGhost != previewGhost
            global previewGhost = newGhost

            redrawTools = true
            Main.redrawLayer!(targetLayer)
        end
    end

    if redrawTools
        Main.redrawLayer!(toolsLayer)
    end
end

# Doesn't matter if this is grid/abs, we only need to know the selection is done
function selectionFinish(rect::Main.Rectangle)
    if previewGhost !== nothing
        pushPreview!(targetLayer, Main.loadedRoom, previewGhost)
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
    global targetLayer = Main.updateLayerList!(layers, wantedLayer, "entities")
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