module Wire

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Wire" => Ahorn.EntityPlacement(
        Maple.Wire,
        "line"
    )
)

function nodeLimits(entity::Maple.Entity)
    if entity.name == "wire"
        return true, 1, 1
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "wire"
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

wireColor = (89, 88, 102, 1) ./ (255, 255, 255, 1)
wireColorSelected = (Ahorn.colors.selection_selected_fc)

function renderWire(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, color::Ahorn.colorTupleType=wireColor)
    x, y = Ahorn.entityTranslation(entity)

    Ahorn.Cairo.save(ctx)
    
    Ahorn.setSourceColor(ctx, color)
    Ahorn.set_antialias(ctx, 1)
    Ahorn.set_line_width(ctx, 1)

    Ahorn.move_to(ctx, x, y)

    for node in get(entity.data, "nodes", ())
        nx, ny = Int.(node)
        dx, dy = nx - x, ny - y

        Ahorn.curve_to(ctx, x + 0.33 * dx, y + 0.33 * dy + abs(dy * 0.5) + 5, x + 0.66 * dx, y + 0.66 * dy + abs(dy * 0.66) + 7, nx, ny)
        Ahorn.move_to(ctx, nx, ny)
    end

    Ahorn.stroke(ctx)

    Ahorn.Cairo.restore(ctx)
end

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity)
    if entity.name == "wire"
        renderWire(ctx, entity, wireColorSelected)

        return true
    end

    return false
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "wire"
        renderWire(ctx, entity, wireColor)

        return true
    end

    return false
end

end