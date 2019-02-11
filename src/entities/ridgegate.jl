module RidgeGate

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Ridge Gate" => Ahorn.EntityPlacement(
        Maple.RidgeGate,
        "point",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + 40, Int(entity.data["y"]))]
        end
    )
)

Ahorn.nodeLimits(entity::Maple.RidgeGate) = 0, 1

Ahorn.resizable(entity::Maple.RidgeGate) = false, false

sprite = "objects/ridgeGate.png"

function Ahorn.selection(entity::Maple.RidgeGate)
    x, y = Ahorn.position(entity)

    nodes = get(entity.data, "nodes", ())
    if isempty(nodes)
        return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.5, jy=0.0)

    else
        nx, ny = Int.(nodes[1])

        return [Ahorn.getSpriteRectangle(sprite, x, y, jx=0.5, jy=0.0), Ahorn.getSpriteRectangle(sprite, nx, ny, jx=0.5, jy=0.0)]
    end
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.RidgeGate)
    x, y = Ahorn.position(entity)
    nodes = get(entity.data, "nodes", ())
    
    if !isempty(nodes)
        nx, ny = Int.(nodes[1])

        Ahorn.drawSprite(ctx, sprite, nx, ny, jx=0.5, jy=0.0)
        Ahorn.drawArrow(ctx, x, y + 16, nx, ny + 16, Ahorn.colors.selection_selected_fc, headLength=6)
    end
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.RidgeGate, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, 0, jx=0.5, jy=0.0)

end