module ObjectTile

using ..Ahorn, Maple

displayName = "Object Tiles"
group = "Placements"

drawingLayers = Ahorn.Layer[]

toolsLayer = nothing
targetLayer = nothing
entityLayer = nothing

material = -1

position = nothing

function idToDisplayName(id::Int)
    return get(Ahorn.ObjectTileNames.names, id, string(id))
end

function displayNameToId(name::String)
    for (k, v) in Ahorn.ObjectTileNames.names
        if v == name
            return k
        end
    end

    try
        return parse(Int, name)

    catch
        return -1
    end
end

function drawBrushes(layer::Ahorn.Layer, room::Ahorn.DrawableRoom, camera::Ahorn.Camera)
    if position !== nothing
        ctx = Ahorn.getSurfaceContext(layer.surface)

        Ahorn.drawObjectTile(ctx, position..., material)
    end
end

function cleanup()
    global position = nothing

    Ahorn.redrawLayer!(toolsLayer)
end

function getMaterials()
    materials = String[Ahorn.ObjectTileNames.names[-1]]
    objSprite = Ahorn.getSprite("tilesets/scenery", "Gameplay")

    width = objSprite.realWidth
    height = objSprite.realHeight

    cellWidth = floor(Int, width / 8)
    cellHeight = floor(Int, height / 8)

    surface = Ahorn.CairoImageSurface(zeros(UInt32, width, height), Ahorn.Cairo.FORMAT_ARGB32)
    ctx = Ahorn.CairoContext(surface)

    Ahorn.drawImage(ctx, "tilesets/scenery", 0, 0, atlas="Gameplay")

    data = surface.data

    for x in 0:cellWidth - 1
        for y in 0:cellHeight - 1
            if !all(data[x * 8 + 1:x * 8 + 8, y * 8 + 1:y * 8 + 8] .== 0)
                push!(materials, idToDisplayName(y * cellWidth + x))
            end
        end
    end

    sort!(materials)

    return materials
end

function setMaterials!(layer::Ahorn.Layer)
    Ahorn.setMaterialList!(getMaterials(), row -> row[1] == string(material))
end

function mouseMotion(x::Number, y::Number)
    global position = (x, y)

    Ahorn.redrawLayer!(toolsLayer)
end

function leftClick(x::Number, y::Number)
    Ahorn.History.addSnapshot!(Ahorn.History.RoomSnapshot("Obj Tile Test", Ahorn.loadedState.room))

    Maple.updateTileSize!(Ahorn.loadedState.room, '0', '0')

    data = Ahorn.loadedState.room.objTiles.data
    height, width = size(data)

    dr = Ahorn.getDrawableRoom(Ahorn.loadedState.map, Ahorn.loadedState.room)
    entityLayer = Ahorn.getLayerByName(dr.layers, "entities")

    if 1 <= x <= width && 1 <= y <= height
        data[y, x] = material

        Ahorn.redrawLayer!(entityLayer)
    end
end

function middleClick(x::Number, y::Number)
    global material = get(Ahorn.loadedState.room.objTiles.data, (y, x), -1)

    Ahorn.persistence["objtiles_material"] = material
    Ahorn.selectMaterialList!(string(material))
end

function toolSelected(subTools::Ahorn.ListContainer, layers::Ahorn.ListContainer, materials::Ahorn.ListContainer)
    global material = get(Ahorn.persistence, "objtiles_material", -1)

    Ahorn.updateLayerList!(["objtiles"], 1)

    Ahorn.redrawingFuncs["tools"] = drawBrushes
    Ahorn.redrawLayer!(toolsLayer)
end

function layerSelected(list::Ahorn.ListContainer, materials::Ahorn.ListContainer, selected::String)
    global targetLayer = Ahorn.getLayerByName(drawingLayers, selected)

    setMaterials!(targetLayer)
end

function materialSelected(list::Ahorn.ListContainer, selected::String)
    selectedId = displayNameToId(selected)

    Ahorn.persistence["objtiles_material"] = selectedId

    global material = selectedId
end

function materialFiltered(list::Ahorn.ListContainer)
    targetName = idToDisplayName(material)

    Ahorn.selectRow!(list, row -> row[1] == targetName)
end

function getFavorites()
    if targetLayer !== nothing
        key = "favorites_objtiles_$(targetLayer.name)"

        return Ahorn.getFavorites(Ahorn.persistence, key)
    end

    return []
end

function materialDoubleClicked(material::String)
    if targetLayer !== nothing
        key = "favorites_objtiles_$(targetLayer.name)"

        Ahorn.toggleFavorite(Ahorn.persistence, key, material)
        Ahorn.setMaterialList!(getMaterials(), row -> row[1] == material)
        Ahorn.updateMaterialFilter!(targetLayer.name)
    end
end

function layersChanged(layers::Array{Ahorn.Layer, 1})
    global drawingLayers = layers

    global toolsLayer = Ahorn.getLayerByName(layers, "tools")
    global entityLayer = Ahorn.getLayerByName(layers, "entities")
end

end