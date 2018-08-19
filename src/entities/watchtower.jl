module Watchtower

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Watchtower" => Ahorn.EntityPlacement(
        Maple.Towerviewer
    ),
)

function nodeLimits(entity::Maple.Entity)
    if entity.name == "towerviewer"
        return true, 0, -1
    end
end

sprite = "objects/lookout/lookout05.png"

function selection(entity::Maple.Entity)
    if entity.name == "towerviewer"
        nodes = get(entity.data, "nodes", ())
        x, y = Ahorn.entityTranslation(entity)

        res = Ahorn.Rectangle[Ahorn.Rectangle(x - 8, y - 16, 16, 16)]
        
        for node in nodes
            nx, ny = Int.(node)

            push!(res, Ahorn.Rectangle(nx - 8, ny - 16, 16, 16))
        end

        return true, res
    end
end

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity)
    if entity.name == "towerviewer"
        px, py = Ahorn.entityTranslation(entity)

        for node in get(entity.data, "nodes", ())
            nx, ny = Int.(node)

            theta = atan2(py - ny, px - nx)
            Ahorn.drawArrow(ctx, px, py - 8, nx + cos(theta) * 8, ny + sin(theta) * 8 - 8, Ahorn.colors.selection_selected_fc, headLength=6)
            Ahorn.drawSprite(ctx, sprite, nx, ny - 16)

            px, py = nx, ny
        end
    end
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "towerviewer"
        x, y = Ahorn.entityTranslation(entity)
        Ahorn.drawSprite(ctx, sprite, x, y - 16)

        return true
    end

    return false
end

end