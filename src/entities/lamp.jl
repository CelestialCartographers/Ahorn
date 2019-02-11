module Lamp

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Lamp" => Ahorn.EntityPlacement(
        Maple.Lamp
    ),
    "Lamp (Broken)" => Ahorn.EntityPlacement(
        Maple.BrokenLamp
    ), 
)

function Ahorn.selection(entity::Maple.Lamp)
    sprite = Ahorn.getSprite("scenery/lamp", "Gameplay")
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - floor(Int, sprite.width / 4), y - sprite.height, floor(Int, sprite.width / 2), sprite.height)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Lamp, room::Maple.Room)
    sprite = Ahorn.getSprite("scenery/lamp", "Gameplay")

    width = floor(Int, sprite.width / 2)
    height = sprite.height
    
    broken = get(entity.data, "broken", false)
    Ahorn.drawImage(ctx, sprite, -floor(Int, width / 2), -height, width * broken, 0, width, height)
end

end