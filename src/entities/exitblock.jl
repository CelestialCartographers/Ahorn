module ExitBlock

placements = Dict{String, Main.EntityPlacement}(
    "Exit Block" => Main.EntityPlacement(
        Main.Maple.ExitBlock,
        "rectangle",
        Dict{String, Any}(),
        Main.tileEntityFinalizer
    ),
)

function editingOptions(entity::Main.Maple.Entity)
    if entity.name == "exitBlock"
        return true, Dict{String, Any}(
            "tileType" => string.(Main.Maple.tile_entity_legal_tiles)
        )
    end
end

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "exitBlock"
        return true, 8, 8
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "exitBlock"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "exitBlock"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Main.Rectangle(x, y, width, height)
    end
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "exitBlock"
        Main.drawTileEntity(ctx, room, entity, alpha=0.5)

        return true
    end

    return false
end

end