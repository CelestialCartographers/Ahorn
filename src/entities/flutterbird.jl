module FlutterBird

placements = Dict{String, Main.EntityPlacement}(
    "Flutterbird" => Main.EntityPlacement(
        Main.Maple.Flutterbird
    ),
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "flutterbird"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 4, y - 8, 8, 8)
    end
end

# TODO - Tint later when possible
function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "flutterbird"
        Main.drawSprite(ctx, "scenery/flutterbird/idle00.png", 0, -5)

        return true
    end
end

end