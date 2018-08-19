module Seeker

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Seeker" => Ahorn.EntityPlacement(
        Maple.Seeker,
        "point",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + 32, Int(entity.data["y"]))]
        end
    )
)

function nodeLimits(entity::Maple.Entity)
    if entity.name == "seeker"
        return true, 1, -1
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "seeker"
        nodes = get(entity.data, "nodes", ())
        x, y = Ahorn.entityTranslation(entity)

        res = Ahorn.Rectangle[Ahorn.Rectangle(x - 8, y - 8, 20, 20)]
        
        for node in nodes
            nx, ny = node

            push!(res, Ahorn.Rectangle(nx - 8, ny - 8, 20, 20))
        end

        return true, res
    end
end

sprite = "characters/monsters/predator73.png"

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity)
    if entity.name == "seeker"
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

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "seeker"
        Ahorn.drawSprite(ctx, sprite, 0, 0)

        return true
    end

    return false
end

end