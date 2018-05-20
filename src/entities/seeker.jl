module Seeker

placements = Dict{String, Main.EntityPlacement}(
    "Seeker" => Main.EntityPlacement(
        Main.Maple.Seeker,
        "point",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + 32, Int(entity.data["y"]))]
        end
    )
)

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "seeker"
        return true, 1, -1
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "seeker"
        nodes = get(entity.data, "nodes", ())
        x, y = Main.entityTranslation(entity)

        res = Main.Rectangle[Main.Rectangle(x - 8, y - 8, 20, 20)]
        
        for node in nodes
            nx, ny = node

            push!(res, Main.Rectangle(nx - 8, ny - 8, 20, 20))
        end

        return true, res
    end
end

sprite = "characters/monsters/predator73.png"

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity)
    if entity.name == "seeker"
        px, py = Main.entityTranslation(entity)

        for node in get(entity.data, "nodes", ())
            nx, ny = Int.(node)

            theta = atan2(py - ny, px - nx)
            Main.drawArrow(ctx, px, py, nx + cos(theta) * 8, ny + sin(theta) * 8, Main.colors.selection_selected_fc, headLength=6)
            Main.drawSprite(ctx, sprite, nx, ny)

            px, py = nx, ny
        end
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "seeker"
        Main.drawSprite(ctx, sprite, 0, 0)

        return true
    end

    return false
end

end