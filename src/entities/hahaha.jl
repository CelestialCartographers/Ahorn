module Hahaha

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Hahaha" => Ahorn.EntityPlacement(
        Maple.Hahaha,
        "point",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + 40, Int(entity.data["y"]))]
        end
    )
)

Ahorn.nodeLimits(entity::Maple.Hahaha) = 0, 1

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Hahaha)
    x, y = Ahorn.position(entity)

    nodes = get(entity.data, "nodes", [])

    if !isempty(nodes)
        nx, ny = nodes[1]

        Ahorn.drawArrow(ctx, x, y, nx, ny, Ahorn.colors.selection_selected_fc, headLength=6)
        Ahorn.drawSprite(ctx, "characters/oldlady/ha00.png", nx - 11, ny - 1)
        Ahorn.drawSprite(ctx, "characters/oldlady/ha00.png", nx, ny + 1)
        Ahorn.drawSprite(ctx, "characters/oldlady/ha00.png", nx + 11, ny - 1)
    end
end

sprite = "characters/oldlady/ha00.png"

function Ahorn.selection(entity::Maple.Hahaha)
    x, y = Ahorn.position(entity)
    nodes = get(entity.data, "nodes", [])

    if isempty(nodes)
        return Ahorn.coverRectangles([
            Ahorn.getSpriteRectangle(sprite, x - 11, y - 1),
            Ahorn.getSpriteRectangle(sprite, x, y + 1),
            Ahorn.getSpriteRectangle(sprite, x + 11, y - 1),
        ])

    else
        nx, ny = nodes[1]

        return [
                Ahorn.coverRectangles([
                Ahorn.getSpriteRectangle(sprite, x - 11, y - 1),
                Ahorn.getSpriteRectangle(sprite, x, y + 1),
                Ahorn.getSpriteRectangle(sprite, x + 11, y - 1),
            ]),
            Ahorn.coverRectangles([
                Ahorn.getSpriteRectangle(sprite, nx - 11, ny - 1),
                Ahorn.getSpriteRectangle(sprite, nx, ny + 1),
                Ahorn.getSpriteRectangle(sprite, nx + 11, ny - 1),
            ])
        ]
    end
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Hahaha, room::Maple.Room)
    Ahorn.drawSprite(ctx, sprite, -11, -1)
    Ahorn.drawSprite(ctx, sprite, 0, 1)
    Ahorn.drawSprite(ctx, sprite, 11, -1)
end

end