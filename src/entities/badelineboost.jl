module BadelineBoost

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Badeline Boost" => Ahorn.EntityPlacement(
        Maple.BadelineBoost
    ),
)

function nodeLimits(entity::Maple.Entity)
    if entity.name == "badelineBoost"
        return true, 0, -1
    end
end

sprite = "objects/badelineboost/idle00.png"

function selection(entity::Maple.Entity)
    if entity.name == "badelineBoost"
        nodes = get(entity.data, "nodes", ())
        x, y = Ahorn.entityTranslation(entity)

        res = Ahorn.Rectangle[Ahorn.Rectangle(x - 8, y - 8, 16, 16)]
        
        for node in nodes
            nx, ny = Int.(node)

            push!(res, Ahorn.Rectangle(nx - 6, ny - 6, 12, 12))
        end

        return true, res
    end
end

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity)
    if entity.name == "badelineBoost"
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
    if entity.name == "badelineBoost"
        x, y = Ahorn.entityTranslation(entity)
        Ahorn.drawSprite(ctx, sprite, x, y)

        return true
    end

    return false
end

end