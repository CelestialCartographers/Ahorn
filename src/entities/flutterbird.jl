module FlutterBird

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Flutterbird" => Ahorn.EntityPlacement(
        Maple.Flutterbird
    ),
)

function selection(entity::Maple.Entity)
    if entity.name == "flutterbird"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 4, y - 8, 8, 8)
    end
end

# TODO - Tint later when possible
function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "flutterbird"
        Ahorn.drawSprite(ctx, "scenery/flutterbird/idle00.png", 0, -5)

        return true
    end
end

end