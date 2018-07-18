module BadelineBoss

placements = Dict{String, Main.EntityPlacement}(
    "Badeline Boss" => Main.EntityPlacement(
        Main.Maple.BadelineBoss,
    )
)

function editingOptions(entity::Main.Maple.Entity)
    if entity.name == "finalBoss"
        return true, Dict{String, Any}(
            "patternIndex" => Main.Maple.badeline_boss_shooting_patterns
        )
    end
end

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "finalBoss"
        return true, 0, -1
    end
end

sprite = "characters/badelineBoss/charge00.png"

function selection(entity::Main.Maple.Entity)
    if entity.name == "finalBoss"
        nodes = get(entity.data, "nodes", ())
        x, y = Main.entityTranslation(entity)

        res = Main.Rectangle[Main.Rectangle(x - 18, y - 12, 36, 28)]
        
        for node in nodes
            nx, ny = Int.(node)

            push!(res, Main.Rectangle(nx - 18, ny - 12, 36, 28))
        end

        return true, res
    end
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity)
    if entity.name == "finalBoss"
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

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "finalBoss"
        x, y = Main.entityTranslation(entity)
        Main.drawSprite(ctx, sprite, x, y)

        return true
    end

    return false
end

end