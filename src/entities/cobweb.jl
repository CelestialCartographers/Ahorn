module Cobweb

placements = Dict{String, Main.EntityPlacement}(
    "Cobweb" => Main.EntityPlacement(
        Main.Maple.Cobweb,
        "line"
    )
)

cobwebColor = (41, 42, 42, 1) ./ (255, 255, 255, 1)
cobwebColorSelected = (Main.colors.selection_selected_fc)

function renderCobweb(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, color::Main.colorTupleType=cobwebColor)
    x, y = Main.entityTranslation(entity)

    Main.Cairo.save(ctx)
    
    Main.setSourceColor(ctx, color)
    Main.set_antialias(ctx, 1)
    Main.set_line_width(ctx, 1)

    nodes = get(entity.data, "nodes", [])
    nx, ny = Int.(nodes[1])
    dx, dy = nx - x, ny - y

    centerX, centerY = round(Int, x + 0.66 * dx), round(Int, y + 0.66 * dy + abs(dy * 0.3))

    Main.move_to(ctx, x, y)
    Main.curve_to(ctx, x + 0.33 * dx, y + 0.33 * dy + abs(dy * 0.2) + 5, x + 0.66 * dx, y + 0.66 * dy + abs(dy * 0.3) + 7, nx, ny)

    for node in nodes
        Main.move_to(ctx, centerX, centerY)

        nx, ny = Int.(node)
        dx, dy = nx - centerX, ny - centerY

        Main.curve_to(ctx, centerX + 0.33 * dx, centerY + 0.33 * dy + abs(dy * 0.2) + 5, centerX + 0.66 * dx, centerY + 0.66 * dy + abs(dy * 0.3) + 7, nx, ny)
    end

    Main.stroke(ctx)

    Main.Cairo.restore(ctx)
end

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "cobweb"
        return true, 1, -1
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "cobweb"
        nodes = get(entity.data, "nodes", ())
        x, y = Main.entityTranslation(entity)

        res = Main.Rectangle[Main.Rectangle(x - 4, y - 4, 8, 8)]
        
        for node in nodes
            nx, ny = node

            push!(res, Main.Rectangle(nx - 4, ny - 4, 8, 8))
        end

        return true, res
    end
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "cobweb"
        renderCobweb(ctx, entity, cobwebColor)

        return true
    end

    return false
end

end