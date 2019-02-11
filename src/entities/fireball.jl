module FireBall

using ..Ahorn, Maple

function fireballFinalizer(entity::Maple.FireBall)
    x, y = Ahorn.position(entity)


    entity.data["nodes"] = [(x + 16, y)]
end

const placements = Ahorn.PlacementDict(
    "Fireball" => Ahorn.EntityPlacement(
        Maple.FireBall,
        "point",
        Dict{String, Any}(
            "amount" => 3
        ),
        fireballFinalizer
    )
)

Ahorn.nodeLimits(entity::Maple.FireBall) = 1, -1

sprite = "objects/fireball/fireball01.png"

function Ahorn.selection(entity::Maple.FireBall)
    nodes = get(entity.data, "nodes", ())
    x, y = Ahorn.position(entity)

    res = Ahorn.Rectangle[Ahorn.getSpriteRectangle(sprite, x, y)]
    
    for node in nodes
        nx, ny = Int.(node)

        push!(res, Ahorn.getSpriteRectangle(sprite, nx, ny))
    end

    return res
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.FireBall)
    px, py = Ahorn.position(entity)

    for node in get(entity.data, "nodes", ())
        nx, ny = Int.(node)

        Ahorn.drawArrow(ctx, px, py, nx, ny, Ahorn.colors.selection_selected_fc, headLength=6)
        Ahorn.drawSprite(ctx, sprite, nx, ny)

        px, py = nx, ny
    end
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.FireBall, room::Maple.Room)
    x, y = Ahorn.position(entity)
    Ahorn.drawSprite(ctx, sprite, x, y)
end

end