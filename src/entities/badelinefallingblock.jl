module BadelineFallingBlock

using ..Ahorn, Maple

# We place a FallingBlock with some preset data instead
# But it might still exist from loading base game maps

placements = Dict{String, Ahorn.EntityPlacement}(
    "Badeline Boss Falling Block" => Ahorn.EntityPlacement(
        Maple.BadelineFallingBlock,
        "rectangle",
    )
)

function minimumSize(entity::Maple.Entity)
    if entity.name == "finalBossFallingBlock"
        return true, 8, 8
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "finalBossFallingBlock"
        return true, true, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "finalBossFallingBlock"
        x, y = Ahorn.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Ahorn.Rectangle(x, y, width, height)
    end
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "finalBossFallingBlock"
        Ahorn.drawTileEntity(ctx, room, entity, material='g')

        return true
    end

    return false
end

end