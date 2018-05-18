module Booster

placements = Dict{String, Main.EntityPlacement}(
    "Booster (Green)" => Main.EntityPlacement(
        Main.Maple.GreenBooster
    ),
    "Booster (Red)" => Main.EntityPlacement(
        Main.Maple.RedBooster
    )
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "booster"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 8, y - 8, 16, 16)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "booster"
        red = get(entity.data, "red", false)

        if red
            Main.drawSprite(ctx, "objects/booster/boosterRed00.png", 0, 0)

        else
            Main.drawSprite(ctx, "objects/booster/booster00.png", 0, 0)
        end

        return true
    end

    return false
end

end