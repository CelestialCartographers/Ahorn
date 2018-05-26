module CoverupWall

placements = Dict{String, Main.EntityPlacement}(
    "Coverup Wall" => Main.EntityPlacement(
        Main.Maple.CoverupWall,
        "rectangle",
        Dict{String, Any}(),
        function(entity)
            entity.data["tiletype"] = get(Main.persistence, "brushes_material", Main.Maple.tile_names["Snow"])
        end
    ),
)

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "coverupWall"
        return true, 8, 8
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "coverupWall"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "coverupWall"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Main.Rectangle(x, y, width, height)
    end
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "coverupWall"
        Main.drawTileEntity(ctx, room, entity, alpha=0.5)

        return true
    end

    return false
end

end