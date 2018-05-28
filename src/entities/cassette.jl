module Cassette

placements = Dict{String, Main.EntityPlacement}(
    "Cassette" => Main.EntityPlacement(
        Main.Maple.Cassette,
        "point",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [
                (Int(entity.data["x"]) + 32, Int(entity.data["y"])),
                (Int(entity.data["x"]) + 64, Int(entity.data["y"]))
            ]
        end
    ),
)

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "cassette"
        return true, 2, 2
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "cassette"
        x, y = Main.entityTranslation(entity)
        nx1, ny1 = Int.(entity.data["nodes"][1])
        nx2, ny2 = Int.(entity.data["nodes"][2])

        return true, [Main.Rectangle(x - 12, y - 8, 24, 16), Main.Rectangle(nx1 - 12, ny1 - 8, 24, 16), Main.Rectangle(nx2 - 12, ny2 - 8, 24, 16)]
    end
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity)
    if entity.name == "cassette"
        px, py = Main.entityTranslation(entity)
        nodes = entity.data["nodes"]

        for node in nodes
            nx, ny = Int.(node)
            theta = atan2(py - ny, px - nx)
            Main.drawArrow(ctx, px, py, nx + cos(theta) * 8, ny + sin(theta) * 8, Main.colors.selection_selected_fc, headLength=6)
            Main.drawSprite(ctx, "collectables/cassette/idle00.png", nx, ny)
            px, py = nx, ny
        end
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