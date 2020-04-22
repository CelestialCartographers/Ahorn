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

defaultTexture = "objects/ridgeGate"

function Ahorn.selection(entity::Maple.RidgeGate)
    x, y = Ahorn.position(entity)
    nodes = get(entity.data, "nodes", ())

    texture = get(entity.data, "texture", defaultTexture)

    if isempty(nodes)
        return Ahorn.getSpriteRectangle(texture, x, y)

    else
        nx, ny = Int.(nodes[1])

        return [Ahorn.getSpriteRectangle(texture, x, y, jx=0.0, jy=0.0), Ahorn.getSpriteRectangle(texture, nx, ny, jx=0.0, jy=0.0)]
    end
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.RidgeGate)
    x, y = Ahorn.position(entity)
    nodes = get(entity.data, "nodes", ())

    texture = get(entity.data, "texture", defaultTexture)
    sprite = Ahorn.getSprite(texture, "Gameplay")
    
    if !isempty(nodes)
        nx, ny = Int.(nodes[1])

        offsetX, offsetY = floor(Int, sprite.width / 2), floor(Int, sprite.height / 2)

        Ahorn.drawSprite(ctx, texture, nx, ny, jx=0.0, jy=0.0)
        Ahorn.drawArrow(ctx, nx + offsetX, ny + offsetY, x + offsetX, y + offsetY, Ahorn.colors.selection_selected_fc, headLength=6)
    end
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.RidgeGate, room::Maple.Room)
    texture = get(entity.data, "texture", defaultTexture)

    Ahorn.drawSprite(ctx, texture, 0, 0, jx=0.0, jy=0.0)
end

end