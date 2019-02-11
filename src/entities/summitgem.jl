module SummitGem

using ..Ahorn, Maple

# Not placeable, way to hardcoded
const placements = Ahorn.PlacementDict()

function gemSprite(entity::Maple.SummitGem)
    index = get(entity.data, "gem", 0)

    return "collectables/summitgems/$index/gem00.png"
end

function Ahorn.selection(entity::Maple.SummitGem)
    x, y = Ahorn.position(entity)
    sprite = gemSprite(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.SummitGem, room::Maple.Room)
    sprite = gemSprite(entity)

    Ahorn.drawSprite(ctx, sprite, 0, 0)
end

# Nothing to render, way to hardcoded to work with
Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.SummitGemManager, room::Maple.Room) = true

end