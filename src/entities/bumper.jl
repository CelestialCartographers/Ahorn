module Bumper

placements = Dict{String, Main.EntityPlacement}(
    "Bumper" => Main.EntityPlacement(
        Main.Maple.Bumper
    )
)

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "bigSpinner"
        return true, 0, 1
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "bigSpinner"
        x, y = Main.entityTranslation(entity)
        nodes = get(entity.data, "nodes", ())

        if !isempty(nodes)
            nx, ny = Int.(nodes[1])
            return true, [Main.Rectangle(x - 10, y - 10, 20, 20), Main.Rectangle(nx - 10, ny - 10, 20, 20)]
        end

        return true, Main.Rectangle(x - 10, y - 10, 20, 20)
    end
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity)
    if entity.name == "bigSpinner"
        x, y = Main.entityTranslation(entity)
        nodes = get(entity.data, "nodes", ())

        if !isempty(nodes)
            nx, ny = Int.(nodes[1])

            theta = atan2(y - ny, x - nx)
            Main.drawArrow(ctx, x, y, nx + cos(theta) * 8, ny + sin(theta) * 8, Main.colors.selection_selected_fc, headLength=6)
            Main.drawSprite(ctx, "objects/Bumper/Idle22.png", nx, ny)
        end
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "bigSpinner"
        Main.drawSprite(ctx, "objects/Bumper/Idle22.png", 0, 0)

        return true
    end

    return false
end

end