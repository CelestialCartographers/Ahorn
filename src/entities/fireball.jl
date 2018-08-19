module FireBall

using ..Ahorn, Maple

function fireballFinalizer(entity::Maple.Entity)
    x, y = Ahorn.entityTranslation(entity)


    entity.data["nodes"] = [(x + 16, y)]
end

placements = Dict{String, Ahorn.EntityPlacement}(
    "Fireball" => Ahorn.EntityPlacement(
        Maple.FireBall,
        "point",
        Dict{String, Any}(
            "amount" => 3
        ),
        fireballFinalizer
    )
)

function nodeLimits(entity::Maple.Entity)
    if entity.name == "fireBall"
        return true, 1, -1
    end
end

sprite = "objects/fireball/fireball01.png"

function selection(entity::Maple.Entity)
    if entity.name == "fireBall"
        nodes = get(entity.data, "nodes", ())
        x, y = Ahorn.entityTranslation(entity)

        res = Ahorn.Rectangle[Ahorn.Rectangle(x - 8, y - 8, 16, 16)]
        
        for node in nodes
            nx, ny = Int.(node)

            push!(res, Ahorn.Rectangle(nx - 8, ny - 8, 16, 16))
        end

        return true, res
    end
end

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity)
    if entity.name == "fireBall"
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
    if entity.name == "fireBall"
        x, y = Ahorn.entityTranslation(entity)
        Ahorn.drawSprite(ctx, sprite, x, y)

        return true
    end

    return false
end

end