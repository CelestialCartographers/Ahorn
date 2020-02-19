module Key

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Key" => Ahorn.EntityPlacement(
        Maple.Key
    ),
    "Key (With Return)" => Ahorn.EntityPlacement(
        Maple.Key,
        "point",
        Dict{String, Any}(),
        function(entity::Maple.Key)
            entity.data["nodes"] = [
                (Int(entity.data["x"]) + 32, Int(entity.data["y"])),
                (Int(entity.data["x"]) + 64, Int(entity.data["y"]))
            ]
        end
    ),
)

Ahorn.nodeLimits(entity::Maple.Key) = length(get(entity.data, "nodes", [])) == 2 ? (2, 2) : (0, 0)

sprite = "collectables/key/idle00.png"

function Ahorn.selection(entity::Maple.Key)
    x, y = Ahorn.position(entity)

    if haskey(entity.data, "nodes") && length(entity["nodes"]) >= 2
        controllX, controllY = Int.(entity.data["nodes"][1])
        endX, endY = Int.(entity.data["nodes"][2])

        return [
            Ahorn.getSpriteRectangle(sprite, x, y),
            Ahorn.getSpriteRectangle(sprite, controllX, controllY),
            Ahorn.getSpriteRectangle(sprite, endX, endY)
        ]

    else
        return Ahorn.getSpriteRectangle(sprite, x, y)
    end
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Key)
    px, py = Ahorn.position(entity)
    nodes = get(entity.data, "nodes", Tuple{Int, Int}[])

    for node in nodes
        nx, ny = Int.(node)

        Ahorn.drawArrow(ctx, px, py, nx, ny, Ahorn.colors.selection_selected_fc, headLength=6)
        Ahorn.drawSprite(ctx, sprite, nx, ny)
        px, py = nx, ny
    end
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Key, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, 0)

end