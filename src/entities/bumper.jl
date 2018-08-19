module Bumper

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Bumper" => Ahorn.EntityPlacement(
        Maple.Bumper
    )
)

function nodeLimits(entity::Maple.Entity)
    if entity.name == "bigSpinner"
        return true, 0, 1
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "bigSpinner"
        x, y = Ahorn.entityTranslation(entity)
        nodes = get(entity.data, "nodes", ())

        if !isempty(nodes)
            nx, ny = Int.(nodes[1])
            return true, [Ahorn.Rectangle(x - 10, y - 10, 20, 20), Ahorn.Rectangle(nx - 10, ny - 10, 20, 20)]
        end

        return true, Ahorn.Rectangle(x - 10, y - 10, 20, 20)
    end
end

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity)
    if entity.name == "bigSpinner"
        x, y = Ahorn.entityTranslation(entity)
        nodes = get(entity.data, "nodes", ())

        if !isempty(nodes)
            nx, ny = Int.(nodes[1])

            theta = atan2(y - ny, x - nx)
            Ahorn.drawArrow(ctx, x, y, nx + cos(theta) * 8, ny + sin(theta) * 8, Ahorn.colors.selection_selected_fc, headLength=6)
            Ahorn.drawSprite(ctx, "objects/Bumper/Idle22.png", nx, ny)
        end
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "bigSpinner"
        Ahorn.drawSprite(ctx, "objects/Bumper/Idle22.png", 0, 0)

        return true
    end

    return false
end

end