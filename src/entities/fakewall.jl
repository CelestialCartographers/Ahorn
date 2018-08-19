module FakeWall

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Fake Wall" => Ahorn.EntityPlacement(
        Maple.FakeWall,
        "rectangle",
        Dict{String, Any}(),
        Ahorn.tileEntityFinalizer
    ),
)

function editingOptions(entity::Maple.Entity)
    if entity.name == "fakeWall"
        return true, Dict{String, Any}(
            "tiletype" => string.(Maple.tile_entity_legal_tiles)
        )
    end
end

function minimumSize(entity::Maple.Entity)
    if entity.name == "fakeWall"
        return true, 8, 8
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "fakeWall"
        return true, true, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "fakeWall"
        x, y = Ahorn.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Ahorn.Rectangle(x, y, width, height)
    end
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "fakeWall"
        Ahorn.drawTileEntity(ctx, room, entity, alpha=0.5)

        return true
    end

    return false
end

end