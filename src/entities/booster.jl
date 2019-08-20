module Booster

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Booster (Green)" => Ahorn.EntityPlacement(
        Maple.GreenBooster
    ),
    "Booster (Red)" => Ahorn.EntityPlacement(
        Maple.RedBooster
    )
)

function boosterSprite(entity::Maple.Booster)
    red = get(entity.data, "red", false)
    
    if red
        return "objects/booster/boosterRed00"

    else
        return "objects/booster/booster00"
    end
end

function Ahorn.selection(entity::Maple.Booster)
    x, y = Ahorn.position(entity)
    sprite = boosterSprite(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Booster, room::Maple.Room)
    sprite = boosterSprite(entity)

    Ahorn.drawSprite(ctx, sprite, 0, 0)
end

end