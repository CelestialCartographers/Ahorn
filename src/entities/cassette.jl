module Cassette

placements = Dict{String, Main.EntityPlacement}(
    "Cassette" => Main.EntityPlacement(
        Main.Maple.Cassette,
        "point",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + 28, Int(entity.data["y"]))]
        end
    ),
)

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "cassette"
        return true, 1, 1
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "cassette"
        x, y = Main.entityTranslation(entity)
        nx, ny = Int.(entity.data["nodes"][1])

        return true, [Main.Rectangle(x - 12, y - 8, 24, 16), Main.Rectangle(nx - 12, ny - 8, 24, 16)]
    end
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity)
    if entity.name == "cassette"
        x, y = Main.entityTranslation(entity)
        nx, ny = Int.(entity.data["nodes"][1])

        theta = atan2(y - ny, x - nx)
        Main.drawArrow(ctx, x, y, nx + cos(theta) * 8, ny + sin(theta) * 8, Main.colors.selection_selected_fc, headLength=6)
        Main.drawSprite(ctx, "collectables/cassette/idle00.png", nx, ny)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "cassette"
        Main.drawSprite(ctx, "collectables/cassette/idle00.png", 0, 0)

        return true
    end

    return false
end

end