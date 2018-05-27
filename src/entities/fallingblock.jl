module FallingBlock

placements = Dict{String, Main.EntityPlacement}(
    "Falling Block" => Main.EntityPlacement(
        Main.Maple.FallingBlock,
        "rectangle",
        Dict{String, Any}(),
        Main.tileEntityFinalizer
    ),
)

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "fallingBlock"
        return true, 8, 8
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "fallingBlock"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "fallingBlock"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Main.Rectangle(x, y, width, height)
    end
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "fallingBlock"
        Main.drawTileEntity(ctx, room, entity)

        return true
    end

    return false
end

end