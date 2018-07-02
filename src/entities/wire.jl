module Wire

placements = Dict{String, Main.EntityPlacement}(
    "Wire" => Main.EntityPlacement(
        Main.Maple.Wire,
        "line"
    )
)

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "wire"
        return true, 1, 1
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "wire"
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

wireColor = (89, 88, 102, 1) ./ (255, 255, 255, 1)
wireColorSelected = (Main.colors.selection_selected_fc)

function renderWire(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, color::Main.colorTupleType=wireColor)
    x, y = Main.entityTranslation(entity)

    Main.Cairo.save(ctx)
    
    Main.setSourceColor(ctx, color)
    Main.set_antialias(ctx, 1)
    Main.set_line_width(ctx, 1)

    Main.move_to(ctx, x, y)

    for node in get(entity.data, "nodes", ())
        nx, ny = Int.(node)
        dx, dy = nx - x, ny - y

        Main.curve_to(ctx, x + 0.33 * dx, y + 0.33 * dy + abs(dy * 0.5) + 5, x + 0.66 * dx, y + 0.66 * dy + abs(dy * 0.66) + 7, nx, ny)
        Main.move_to(ctx, nx, ny)
    end

    Main.stroke(ctx)

    Main.Cairo.restore(ctx)
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity)
    if entity.name == "wire"
        renderWire(ctx, entity, wireColorSelected)

        return true
    end

    return false
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "wire"
        renderWire(ctx, entity, wireColor)

        return true
    end

    return false
end

end