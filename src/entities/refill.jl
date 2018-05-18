module Refill

placements = Dict{String, Main.EntityPlacement}(
    "Refill" => Main.EntityPlacement(
        Main.Maple.Refill
    )
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "refill"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 6, y - 6, 12, 12)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "refill"
        Main.drawSprite(ctx, "objects/refill/idle00.png", 0, 0)

        return true
    end

    return false
end

end