module BadelineMovingBlock

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Badeline Boss Moving Block" => Ahorn.EntityPlacement(
        Maple.BadelineMovingBlock,
        "rectangle",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + Int(entity.data["width"]) + 8, Int(entity.data["y"]))]
        end
    )
)

function nodeLimits(entity::Maple.Entity)
    if entity.name == "finalBossMovingBlock"
        return true, 1, 1
    end
end

function minimumSize(entity::Maple.Entity)
    if entity.name == "finalBossMovingBlock"
        return true, 8, 8
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "finalBossMovingBlock"
        return true, true, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "finalBossMovingBlock"
        x, y = Ahorn.entityTranslation(entity)
        nx, ny = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, [Ahorn.Rectangle(x, y, width, height), Ahorn.Rectangle(nx, ny, width, height)]
    end
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "finalBossMovingBlock"
        Ahorn.drawTileEntity(ctx, room, entity, material='g', blendIn=false)

        return true
    end

    return false
end

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "finalBossMovingBlock"
        x, y = Ahorn.entityTranslation(entity)
        nodes = get(entity.data, "nodes", ())

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))
        
        if !isempty(nodes)
            nx, ny = Int.(nodes[1])

            cox, coy = floor(Int, width / 2), floor(Int, height / 2)

            # Use 'G' instead of 'g', as that is the highlight color of the block (the active color)
            fakeTiles = Ahorn.createFakeTiles(room, nx, ny, width, height, 'G', blendIn=false)
            Ahorn.drawFakeTiles(ctx, room, fakeTiles, true, nx, ny, clipEdges=true)
            Ahorn.drawArrow(ctx, x + cox, y + coy, nx + cox, ny + coy, Ahorn.colors.selection_selected_fc, headLength=6)
        end
    end
end

end