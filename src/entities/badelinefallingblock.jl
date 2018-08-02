module BadelineFallingBlock

# We place a FallingBlock with some preset data instead
# But it might still exist from loading base game maps

placements = Dict{String, Main.EntityPlacement}(
    "Badeline Boss Falling Block" => Main.EntityPlacement(
        Main.Maple.BadelineFallingBlock,
        "rectangle",
    )
)

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "finalBossFallingBlock"
        return true, 8, 8
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "finalBossFallingBlock"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "finalBossFallingBlock"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Main.Rectangle(x, y, width, height)
    end
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "finalBossFallingBlock"
        Main.drawTileEntity(ctx, room, entity, material='g')

        return true
    end

    return false
end

end