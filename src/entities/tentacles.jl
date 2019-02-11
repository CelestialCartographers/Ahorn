module Tentacles

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Tentacles" => Ahorn.EntityPlacement(
        Maple.Tentacles,
        "point",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + 32, Int(entity.data["y"]))]
        end
    )
)

Ahorn.nodeLimits(entity::Maple.Tentacles) = 1, -1

Ahorn.editingOptions(entity::Maple.Tentacles) = Dict{String, Any}(
    "fear_distance" => Maple.tentacle_fear_distance
)

function Ahorn.selection(entity::Maple.Tentacles)
    nodes = get(entity.data, "nodes", ())
    x, y = Ahorn.position(entity)

    res = Ahorn.Rectangle[Ahorn.Rectangle(x - 12, y - 12, 24, 24)]
    
    for node in nodes
        nx, ny = Int.(node)

        push!(res, Ahorn.Rectangle(nx - 12, ny - 12, 24, 24))
    end

    return res
end

function drawTentacleIcon(ctx::Ahorn.Cairo.CairoContext, x::Integer, y::Integer)
    Ahorn.drawImage(ctx, Ahorn.Assets.tentacle, x - 12, y - 12)
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Tentacles)
    px, py = Ahorn.position(entity)

    for node in get(entity.data, "nodes", ())
        nx, ny = Int.(node)

        Ahorn.drawArrow(ctx, px, py, nx, ny, Ahorn.colors.selection_selected_fc, headLength=6)
        drawTentacleIcon(ctx, nx, ny)

        px, py = nx, ny
    end
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Tentacles, room::Maple.Room)
    x, y = Ahorn.position(entity)
    drawTentacleIcon(ctx, x, y)
end

end