module IntroCrusher

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Intro Crusher" => Ahorn.EntityPlacement(
        Maple.IntroCrusher,
        "rectangle",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + Int(entity.data["width"]) + 8, Int(entity.data["y"]))]
            Ahorn.tileEntityFinalizer(entity)
        end,
    ),
)

Ahorn.editingOptions(entity::Maple.IntroCrusher) = Dict{String, Any}(
    "tiletype" => Ahorn.tiletypeEditingOptions()
)

Ahorn.nodeLimits(entity::Maple.IntroCrusher) = 1, 1

Ahorn.minimumSize(entity::Maple.IntroCrusher) = 8, 8
Ahorn.resizable(entity::Maple.IntroCrusher) = true, true

function Ahorn.selection(entity::Maple.IntroCrusher)
    x, y = Ahorn.position(entity)
    nx, ny = Int.(entity.data["nodes"][1])

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))

    return [Ahorn.Rectangle(x, y, width, height), Ahorn.Rectangle(nx, ny, width, height)]
end

Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.IntroCrusher, room::Maple.Room) = Ahorn.drawTileEntity(ctx, room, entity, blendIn=false)

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.IntroCrusher, room::Maple.Room)
    x, y = Ahorn.position(entity)
    nodes = get(entity.data, "nodes", ())

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))
    
    if !isempty(nodes)
        nx, ny = Int.(nodes[1])
        cox, coy = floor(Int, width / 2), floor(Int, height / 2)

        material = get(entity.data, "tiletype", "3")[1] 

        fakeTiles = Ahorn.createFakeTiles(room, nx, ny, width, height, material, blendIn=false)
        Ahorn.drawFakeTiles(ctx, room, fakeTiles, room.objTiles, true, nx, ny, clipEdges=true)
        Ahorn.drawArrow(ctx, x + cox, y + coy, nx + cox, ny + coy, Ahorn.colors.selection_selected_fc, headLength=6)
    end
end

end