module Lamp

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Lamp" => Ahorn.EntityPlacement(
        Maple.Lamp
    ),
    "Lamp (Broken)" => Ahorn.EntityPlacement(
        Maple.BrokenLamp
    ), 
)

function selection(entity::Maple.Entity)
    if entity.name == "lamp"
        sprite = Ahorn.sprites["scenery/lamp"]
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - floor(Int, sprite.width / 4), y - sprite.height, floor(Int, sprite.width / 2), sprite.height)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "lamp"
        sprite = Ahorn.sprites["scenery/lamp"]

        width = floor(Int, sprite.width / 2)
        height = sprite.height
        
        broken = get(entity.data, "broken", false)
        Ahorn.drawImage(ctx, sprite, -floor(Int, width / 2), -height, width * broken, 0, width, height)

        return true
    end

    return false
end

end