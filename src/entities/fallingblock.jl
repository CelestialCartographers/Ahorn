module FallingBlock

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Falling Block" => Ahorn.EntityPlacement(
        Maple.FallingBlock,
        "rectangle",
        Dict{String, Any}(),
        Ahorn.tileEntityFinalizer
    ),
)

function editingOptions(entity::Maple.Entity)
    if entity.name == "fallingBlock"
        return true, Dict{String, Any}(
            "tiletype" => string.(Maple.tile_entity_legal_tiles)
        )
    end
end

function minimumSize(entity::Maple.Entity)
    if entity.name == "fallingBlock"
        return true, 8, 8
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "fallingBlock"
        return true, true, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "fallingBlock"
        x, y = Ahorn.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Ahorn.Rectangle(x, y, width, height)
    end
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "fallingBlock"
        Ahorn.drawTileEntity(ctx, room, entity)

        return true
    end

    return false
end

end