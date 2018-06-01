module PicoConsole

placements = Dict{String, Main.EntityPlacement}(
    "Pico Console" => Main.EntityPlacement(
        Main.Maple.PicoConsole
    )
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "picoconsole"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 20, y - 15, 40, 15)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "picoconsole"
        Main.drawSprite(ctx, "objects/pico8Console", 0, -15)

        return true
    end

    return false
end

end