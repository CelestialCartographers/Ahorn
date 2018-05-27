module DashBlock

placements = Dict{String, Main.EntityPlacement}(
    "Dash Block" => Main.EntityPlacement(
        Main.Maple.DashBlock,
        "rectangle",
        Dict{String, Any}(),
        Main.tileEntityFinalizer
    ),
)

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "dashBlock"
        return true, 8, 8
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "dashBlock"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "dashBlock"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Main.Rectangle(x, y, width, height)
    end
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "dashBlock"
        Main.drawTileEntity(ctx, room, entity)

        return true
    end

    return false
end

end