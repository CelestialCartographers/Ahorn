module BadelineBoost

placements = Dict{String, Main.EntityPlacement}(
    "Badeline Boost" => Main.EntityPlacement(
        Main.Maple.BadelineBoost
    ),
)

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "badelineBoost"
        return true, 0, -1
    end
end

sprite = "objects/badelineboost/idle00.png"

function selection(entity::Main.Maple.Entity)
    if entity.name == "badelineBoost"
        nodes = get(entity.data, "nodes", ())
        x, y = Main.entityTranslation(entity)

        res = Main.Rectangle[Main.Rectangle(x - 8, y - 8, 16, 16)]
        
        for node in nodes
            nx, ny = node

            push!(res, Main.Rectangle(nx - 6, ny - 6, 12, 12))
        end

        return true, res
    end
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity)
    if entity.name == "badelineBoost"
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
    if entity.name == "badelineBoost"
        x, y = Main.entityTranslation(entity)
        nodes = get(entity.data, "nodes", ())

        Main.drawSprite(ctx, sprite, x, y)

        return true
    end

    return false
end

end