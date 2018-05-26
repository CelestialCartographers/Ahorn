module Watchtower

placements = Dict{String, Main.EntityPlacement}(
    "Watchtower" => Main.EntityPlacement(
        Main.Maple.Towerviewer
    ),
)

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "towerviewer"
        return true, 0, -1
    end
end

sprite = "objects/lookout/lookout05.png"

function selection(entity::Main.Maple.Entity)
    if entity.name == "towerviewer"
        nodes = get(entity.data, "nodes", ())
        x, y = Main.entityTranslation(entity)

        res = Main.Rectangle[Main.Rectangle(x - 8, y - 16, 16, 16)]
        
        for node in nodes
            nx, ny = Int.(node)

            push!(res, Main.Rectangle(nx - 8, ny - 16, 16, 16))
        end

        return true, res
    end
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity)
    if entity.name == "towerviewer"
        px, py = Main.entityTranslation(entity)

        for node in get(entity.data, "nodes", ())
            nx, ny = Int.(node)

            theta = atan2(py - ny, px - nx)
            Main.drawArrow(ctx, px, py - 8, nx + cos(theta) * 8, ny + sin(theta) * 8 - 8, Main.colors.selection_selected_fc, headLength=6)
            Main.drawSprite(ctx, sprite, nx, ny - 16)

            px, py = nx, ny
        end
    end
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "towerviewer"
        x, y = Main.entityTranslation(entity)
        Main.drawSprite(ctx, sprite, x, y - 16)

        return true
    end

    return false
end

end