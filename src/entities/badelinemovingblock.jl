module BadelineMovingBlock

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Badeline Boss Moving Block" => Ahorn.EntityPlacement(
        Maple.BadelineMovingBlock,
        "rectangle",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + Int(entity.data["width"]) + 8, Int(entity.data["y"]))]
        end
    )
)

Ahorn.nodeLimits(entity::Maple.BadelineMovingBlock) = 1, 1
Ahorn.minimumSize(entity::Maple.BadelineMovingBlock) = 8, 8
Ahorn.resizable(entity::Maple.BadelineMovingBlock) = true, true

function Ahorn.selection(entity::Maple.BadelineMovingBlock)
    if entity.name == "finalBossMovingBlock"
        x, y = Ahorn.position(entity)
        nx, ny = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return [Ahorn.Rectangle(x, y, width, height), Ahorn.Rectangle(nx, ny, width, height)]
    end
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.BadelineMovingBlock, room::Maple.Room)
    Ahorn.drawTileEntity(ctx, room, entity, material='g', blendIn=false)
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.BadelineMovingBlock, room::Maple.Room)
    x, y = Ahorn.position(entity)
    nodes = get(entity.data, "nodes", ())

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))
    
    if !isempty(nodes)
        nx, ny = Int.(nodes[1])
        cox, coy = floor(Int, width / 2), floor(Int, height / 2)

        # Use 'G' instead of 'g', as that is the highlight color of the block (the active color)
        fakeTiles = Ahorn.createFakeTiles(room, nx, ny, width, height, 'G', blendIn=false)
        Ahorn.drawFakeTiles(ctx, room, fakeTiles, room.objTiles, true, nx, ny, clipEdges=true)
        Ahorn.drawArrow(ctx, x + cox, y + coy, nx + cox, ny + coy, Ahorn.colors.selection_selected_fc, headLength=6)
    end
end

end