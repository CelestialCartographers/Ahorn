module BadelineMovingBlock

placements = Dict{String, Main.EntityPlacement}(
    "Badeline Boss Moving Block" => Main.EntityPlacement(
        Main.Maple.BadelineMovingBlock,
        "rectangle",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + Int(entity.data["width"]) + 8, Int(entity.data["y"]))]
        end
    )
)

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "finalBossMovingBlock"
        return true, 1, 1
    end
end

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "finalBossMovingBlock"
        return true, 8, 8
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "finalBossMovingBlock"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "finalBossMovingBlock"
        x, y = Main.entityTranslation(entity)
        nx, ny = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, [Main.Rectangle(x, y, width, height), Main.Rectangle(nx, ny, width, height)]
    end
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "finalBossMovingBlock"
        Main.drawTileEntity(ctx, room, entity, material='g', blendIn=false)

        return true
    end

    return false
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "finalBossMovingBlock"
        x, y = Main.entityTranslation(entity)
        nodes = get(entity.data, "nodes", ())

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))
        
        if !isempty(nodes)
            nx, ny = Int.(nodes[1])

            cox, coy = floor(Int, width / 2), floor(Int, height / 2)

            # Use 'G' instead of 'g', as that is the highlight color of the block (the active color)
            fakeTiles = Main.createFakeTiles(room, nx, ny, width, height, 'G', blendIn=false)
            Main.drawFakeTiles(ctx, room, fakeTiles, true, nx, ny, clipEdges=true)
            Main.drawArrow(ctx, x + cox, y + coy, nx + cox, ny + coy, Main.colors.selection_selected_fc, headLength=6)
        end
    end
end

end