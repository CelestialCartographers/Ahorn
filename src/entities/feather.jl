module Feather

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Feather" => Ahorn.EntityPlacement(
        Maple.Feather
    ),
    "Feather (Shielded)" => Ahorn.EntityPlacement(
        Maple.Feather,
        "point",
        Dict{String, Any}(
            "shielded" => true
        )
    )
)

function Ahorn.selection(entity::Maple.Feather)
    x, y = Ahorn.position(entity)
    shielded = get(entity.data, "shielded", false)
    
    return shielded ? Ahorn.Rectangle(x - 12, y - 12, 24, 24) : Ahorn.Rectangle(x - 8, y - 8, 16, 16)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Feather, room::Maple.Room)
    if get(entity.data, "shielded", false)
        Ahorn.Cairo.save(ctx)

        Ahorn.set_antialias(ctx, 1)
        Ahorn.set_line_width(ctx, 1);

        Ahorn.drawCircle(ctx, 0, 0, 12, (1.0, 1.0, 1.0, 1.0))

        Ahorn.Cairo.restore(ctx)
    end

    Ahorn.drawSprite(ctx, "objects/flyFeather/idle00.png", 0, 0)
end

end