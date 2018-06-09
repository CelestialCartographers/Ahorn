module Lamp

sprite = Main.sprites["scenery/lamp"]
width = floor(Int, sprite.width / 2)
height = sprite.height

placements = Dict{String, Main.EntityPlacement}(
    "Lamp" => Main.EntityPlacement(
        Main.Maple.Lamp
    ),
    "Lamp (Broken)" => Main.EntityPlacement(
        Main.Maple.BrokenLamp
    ), 
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "lamp"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - floor(Int, width / 2), y - height, width, height)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "lamp"
        broken = get(entity.data, "broken", false)
        Main.drawImage(ctx, sprite, -floor(Int, width / 2), -height, width * broken, 0, width, height)

        return true
    end

    return false
end

end