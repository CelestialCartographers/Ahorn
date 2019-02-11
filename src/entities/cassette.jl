module Cassette

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Cassette" => Ahorn.EntityPlacement(
        Maple.Cassette,
        "point",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [
                (Int(entity.data["x"]) + 32, Int(entity.data["y"])),
                (Int(entity.data["x"]) + 64, Int(entity.data["y"]))
            ]
        end
    ),
)

Ahorn.nodeLimits(entity::Maple.Cassette) = 2, 2

sprite = "collectables/cassette/idle00.png"

function Ahorn.selection(entity::Maple.Cassette)
    x, y = Ahorn.position(entity)
    controllX, controllY = Int.(entity.data["nodes"][1])
    endX, endY = Int.(entity.data["nodes"][2])

    return [
        Ahorn.getSpriteRectangle(sprite, x, y),
        Ahorn.getSpriteRectangle(sprite, controllX, controllY),
        Ahorn.getSpriteRectangle(sprite, endX, endY)
    ]
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Cassette)
    px, py = Ahorn.position(entity)
    nodes = entity.data["nodes"]

    for node in nodes
        nx, ny = Int.(node)

        Ahorn.drawArrow(ctx, px, py, nx, ny, Ahorn.colors.selection_selected_fc, headLength=6)
        Ahorn.drawSprite(ctx, sprite, nx, ny)
        px, py = nx, ny
    end
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Cassette, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, 0)

end