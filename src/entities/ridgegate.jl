module RidgeGate

placements = Dict{String, Main.EntityPlacement}(
    "Ridge Gate" => Main.EntityPlacement(
        Main.Maple.RidgeGate,
        "point",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + 40, Int(entity.data["y"]))]
        end
    )
)

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "ridgeGate"
        return true, 0, 1
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "ridgeGate"
        return true, false, false
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "ridgeGate"
        x, y = Main.entityTranslation(entity)

        nodes = get(entity.data, "nodes", ())
        if isempty(nodes)
            return true, Main.Rectangle(x - 16, y, 32, 32)

        else
            nx, ny = Int.(nodes[1])

            return true, [Main.Rectangle(x - 16, y, 32, 32), Main.Rectangle(nx - 16, ny, 32, 32)]
        end
    end
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity)
    if entity.name == "ridgeGate"
        x, y = Main.entityTranslation(entity)
        nodes = get(entity.data, "nodes", ())
        
        if !isempty(nodes)
            nx, ny = Int.(nodes[1])

            Main.drawSprite(ctx, "objects/ridgeGate.png", nx, ny + 16)
            Main.drawArrow(ctx, x, y + 16, nx, ny + 16, Main.colors.selection_selected_fc, headLength=6)
        end
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "ridgeGate"
        Main.drawSprite(ctx, "objects/ridgeGate.png", 0, 16)

        return true
    end

    return false
end

end