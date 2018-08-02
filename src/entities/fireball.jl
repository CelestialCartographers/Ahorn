module FireBall

function fireballFinalizer(entity::Main.Maple.Entity)
    x, y = Main.entityTranslation(entity)


    entity.data["nodes"] = [(x + 16, y)]
end

placements = Dict{String, Main.EntityPlacement}(
    "Fireball" => Main.EntityPlacement(
        Main.Maple.FireBall,
        "point",
        Dict{String, Any}(
            "amount" => 3
        ),
        fireballFinalizer
    )
)

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "fireBall"
        return true, 1, -1
    end
end

sprite = "objects/fireball/fireball01.png"

function selection(entity::Main.Maple.Entity)
    if entity.name == "fireBall"
        nodes = get(entity.data, "nodes", ())
        x, y = Main.entityTranslation(entity)

        res = Main.Rectangle[Main.Rectangle(x - 8, y - 8, 16, 16)]
        
        for node in nodes
            nx, ny = Int.(node)

            push!(res, Main.Rectangle(nx - 8, ny - 8, 16, 16))
        end

        return true, res
    end
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity)
    if entity.name == "fireBall"
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
    if entity.name == "fireBall"
        x, y = Main.entityTranslation(entity)
        Main.drawSprite(ctx, sprite, x, y)

        return true
    end

    return false
end

end