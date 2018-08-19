module SpaceJam

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Space Jam" => Ahorn.EntityPlacement(
        Maple.DreamBlock,
        "rectangle"
    )
)

function minimumSize(entity::Maple.Entity)
    if entity.name == "dreamBlock"
        return true, 8, 8
    end
end

function nodeLimits(entity::Maple.Entity)
    if entity.name == "dreamBlock"
        return true, 0, 1
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "dreamBlock"
        return true, true, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "dreamBlock"
        x, y = Ahorn.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        nodes = get(entity.data, "nodes", ())
        if isempty(nodes)
            return true, Ahorn.Rectangle(x, y, width, height)

        else
            nx, ny = Int.(nodes[1])
            return true, [Ahorn.Rectangle(x, y, width, height), Ahorn.Rectangle(nx, ny, width, height)]
        end
    end
end

function renderSpaceJam(ctx::Ahorn.Cairo.CairoContext, x::Number, y::Number, width::Number, height::Number)
    Ahorn.Cairo.save(ctx)

    Ahorn.set_antialias(ctx, 1)
    Ahorn.set_line_width(ctx, 1);

    Ahorn.drawRectangle(ctx, x, y, width, height, (0.0, 0.0, 0.0, 0.4), (1.0, 1.0, 1.0, 1.0))

    Ahorn.restore(ctx)
end

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity)
    if entity.name == "dreamBlock"
        x, y = Ahorn.entityTranslation(entity)
        nodes = get(entity.data, "nodes", ())

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))
        
        if !isempty(nodes)
            nx, ny = Int.(nodes[1])

            cox, coy = floor(Int, width / 2), floor(Int, height / 2)

            renderSpaceJam(ctx, nx, ny, width, height)
            Ahorn.drawArrow(ctx, x + cox, y + coy, nx + cox, ny + coy, Ahorn.colors.selection_selected_fc, headLength=6)
        end
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "dreamBlock"
        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        renderSpaceJam(ctx, 0, 0, width, height)

        return true
    end

    return false
end

end