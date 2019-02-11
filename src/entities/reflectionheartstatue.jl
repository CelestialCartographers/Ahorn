module ReflectionHeartStatue

using ..Ahorn, Maple

function statueFinalizer(entity::Maple.ReflectionHeartStatue)
    x, y = Ahorn.position(entity)

    entity.data["nodes"] = [
        (x + 32, y),
        (x + 64, y),
        (x + 96, y),
        (x + 128, y),
        (x, y - 64)
    ]
end

const placements = Ahorn.PlacementDict(
    "Reflection Heart Statue" => Ahorn.EntityPlacement(
        Maple.ReflectionHeartStatue,
        "point",
        Dict{String, Any}(),
        statueFinalizer
    )
)

codeLength = 6

statueSprite = "objects/reflectionHeart/statue.png"
torchSprite = "objects/reflectionHeart/torch00.png"
gemSprite = "objects/reflectionHeart/gem.png"

function hintSprite(i::Integer)
    return "objects/reflectionHeart/hint0$i.png"
end

function Ahorn.selection(entity::Maple.ReflectionHeartStatue)
    x, y = Ahorn.position(entity)

    nodes = get(entity.data, "nodes", [])

    if isempty(nodes)
        return  Ahorn.Rectangle(x - 16, y - 36, 32, 36)

    else
        return vcat(
            Ahorn.getSpriteRectangle(statueSprite, x, y, jx=0.5, jy=1.0),
            [Ahorn.coverRectangles([
                Ahorn.getSpriteRectangle(torchSprite, nodes[i][1] - 32, nodes[i][2] - 64, jx=0.0, jy=0.0),
                Ahorn.getSpriteRectangle(hintSprite(i - 1), nodes[i][1], nodes[i][2] + 28)
            ]) for i in 1:4],
            Ahorn.coverRectangles([
                Ahorn.getSpriteRectangle(gemSprite, nodes[5][1] + (i - (codeLength - 1) / 2) * 24, nodes[5][2])
                for i in 0:codeLength - 1
            ])
        )
    end
end

Ahorn.nodeLimits(entity::Maple.ReflectionHeartStatue) = 5, 5

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.ReflectionHeartStatue)
    x, y = Ahorn.position(entity)

    for node in get(entity.data, "nodes", [])
        nx, ny = Int.(node)

        Ahorn.drawArrow(ctx, x, y, nx, ny, Ahorn.colors.selection_selected_fc, headLength=6)
    end
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.ReflectionHeartStatue, room::Maple.Room)
    x, y = Ahorn.position(entity)

    nodes = get(entity.data, "nodes", [])

    Ahorn.drawSprite(ctx, statueSprite, x, y, jx=0.5, jy=1.0)

    if !isempty(nodes)
        for i in 1:4
            tx, ty = nodes[i]
            Ahorn.drawSprite(ctx, torchSprite, tx - 32, ty - 64, jx=0.0, jy=0.0)
            Ahorn.drawSprite(ctx, hintSprite(i - 1), tx, ty + 28)
        end

        gemX, gemY = nodes[5]

        for i in 0:codeLength - 1
            offsetX = (i - (codeLength - 1) / 2) * 24
            Ahorn.drawSprite(ctx, gemSprite, gemX + offsetX, gemY)
        end
    end
end

end