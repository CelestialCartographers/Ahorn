module RidgeGate

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Ridge Gate" => Ahorn.EntityPlacement(
        Maple.RidgeGate,
        "point",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + 40, Int(entity.data["y"]))]
        end
    )
)

function nodeLimits(entity::Maple.Entity)
    if entity.name == "ridgeGate"
        return true, 0, 1
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "ridgeGate"
        return true, false, false
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "ridgeGate"
        x, y = Ahorn.entityTranslation(entity)

        nodes = get(entity.data, "nodes", ())
        if isempty(nodes)
            return true, Ahorn.Rectangle(x - 16, y, 32, 32)

        else
            nx, ny = Int.(nodes[1])

            return true, [Ahorn.Rectangle(x - 16, y, 32, 32), Ahorn.Rectangle(nx - 16, ny, 32, 32)]
        end
    end
end

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity)
    if entity.name == "ridgeGate"
        x, y = Ahorn.entityTranslation(entity)
        nodes = get(entity.data, "nodes", ())
        
        if !isempty(nodes)
            nx, ny = Int.(nodes[1])

            Ahorn.drawSprite(ctx, "objects/ridgeGate.png", nx, ny + 16)
            Ahorn.drawArrow(ctx, x, y + 16, nx, ny + 16, Ahorn.colors.selection_selected_fc, headLength=6)
        end
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "ridgeGate"
        Ahorn.drawSprite(ctx, "objects/ridgeGate.png", 0, 16)

        return true
    end

    return false
end

end