module Cobweb

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Cobweb" => Ahorn.EntityPlacement(
        Maple.Cobweb,
        "line"
    )
)

cobwebColor = (41, 42, 42, 1) ./ (255, 255, 255, 1)
cobwebColorSelected = (Ahorn.colors.selection_selected_fc)

function renderCobweb(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, color::Ahorn.colorTupleType=cobwebColor)
    x, y = Ahorn.entityTranslation(entity)

    Ahorn.Cairo.save(ctx)
    
    Ahorn.setSourceColor(ctx, color)
    Ahorn.set_antialias(ctx, 1)
    Ahorn.set_line_width(ctx, 1)

    nodes = get(entity.data, "nodes", [])
    nx, ny = Int.(nodes[1])
    dx, dy = nx - x, ny - y

    centerX, centerY = round(Int, x + 0.66 * dx), round(Int, y + 0.66 * dy + abs(dy * 0.3))

    Ahorn.move_to(ctx, x, y)
    Ahorn.curve_to(ctx, x + 0.33 * dx, y + 0.33 * dy + abs(dy * 0.2) + 5, x + 0.66 * dx, y + 0.66 * dy + abs(dy * 0.3) + 7, nx, ny)

    for node in nodes
        Ahorn.move_to(ctx, centerX, centerY)

        nx, ny = Int.(node)
        dx, dy = nx - centerX, ny - centerY

        Ahorn.curve_to(ctx, centerX + 0.33 * dx, centerY + 0.33 * dy + abs(dy * 0.2) + 5, centerX + 0.66 * dx, centerY + 0.66 * dy + abs(dy * 0.3) + 7, nx, ny)
    end

    Ahorn.stroke(ctx)

    Ahorn.Cairo.restore(ctx)
end

function nodeLimits(entity::Maple.Entity)
    if entity.name == "cobweb"
        return true, 1, -1
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "cobweb"
        nodes = get(entity.data, "nodes", ())
        x, y = Ahorn.entityTranslation(entity)

        res = Ahorn.Rectangle[Ahorn.Rectangle(x - 4, y - 4, 8, 8)]
        
        for node in nodes
            nx, ny = node

            push!(res, Ahorn.Rectangle(nx - 4, ny - 4, 8, 8))
        end

        return true, res
    end
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "cobweb"
        renderCobweb(ctx, entity, cobwebColor)

        return true
    end

    return false
end

end