module BadelineBoss

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Badeline Boss" => Ahorn.EntityPlacement(
        Maple.BadelineBoss,
    )
)

function editingOptions(entity::Maple.Entity)
    if entity.name == "finalBoss"
        return true, Dict{String, Any}(
            "patternIndex" => Maple.badeline_boss_shooting_patterns
        )
    end
end

function nodeLimits(entity::Maple.Entity)
    if entity.name == "finalBoss"
        return true, 0, -1
    end
end

sprite = "characters/badelineBoss/charge00.png"

function selection(entity::Maple.Entity)
    if entity.name == "finalBoss"
        nodes = get(entity.data, "nodes", ())
        x, y = Ahorn.entityTranslation(entity)

        res = Ahorn.Rectangle[Ahorn.Rectangle(x - 18, y - 12, 36, 28)]
        
        for node in nodes
            nx, ny = Int.(node)

            push!(res, Ahorn.Rectangle(nx - 18, ny - 12, 36, 28))
        end

        return true, res
    end
end

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity)
    if entity.name == "finalBoss"
        px, py = Ahorn.entityTranslation(entity)

        for node in get(entity.data, "nodes", ())
            nx, ny = Int.(node)

            theta = atan2(py - ny, px - nx)
            Ahorn.drawArrow(ctx, px, py, nx + cos(theta) * 8, ny + sin(theta) * 8, Ahorn.colors.selection_selected_fc, headLength=6)
            Ahorn.drawSprite(ctx, sprite, nx, ny)

            px, py = nx, ny
        end
    end
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "finalBoss"
        x, y = Ahorn.entityTranslation(entity)
        Ahorn.drawSprite(ctx, sprite, x, y)

        return true
    end

    return false
end

end