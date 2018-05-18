module Bumper

placements = Dict{String, Main.EntityPlacement}(
    "Bumper" => Main.EntityPlacement(
        Main.Maple.Bumper
    ),
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "bigSpinner"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 10, y - 10, 20, 20)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "bigSpinner"
        Main.drawSprite(ctx, "objects/Bumper/Idle22.png", 0, 0)

        return true
    end

    return false
end

end