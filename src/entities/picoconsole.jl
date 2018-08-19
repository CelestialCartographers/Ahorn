module PicoConsole

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Pico Console" => Ahorn.EntityPlacement(
        Maple.PicoConsole
    )
)

function selection(entity::Maple.Entity)
    if entity.name == "picoconsole"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 20, y - 15, 40, 15)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "picoconsole"
        Ahorn.drawSprite(ctx, "objects/pico8Console", 0, -15)

        return true
    end

    return false
end

end