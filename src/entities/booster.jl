module Booster

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Booster (Green)" => Ahorn.EntityPlacement(
        Maple.GreenBooster
    ),
    "Booster (Red)" => Ahorn.EntityPlacement(
        Maple.RedBooster
    )
)

function selection(entity::Maple.Entity)
    if entity.name == "booster"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 8, y - 8, 16, 16)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "booster"
        red = get(entity.data, "red", false)

        if red
            Ahorn.drawSprite(ctx, "objects/booster/boosterRed00.png", 0, 0)

        else
            Ahorn.drawSprite(ctx, "objects/booster/booster00.png", 0, 0)
        end

        return true
    end

    return false
end

end