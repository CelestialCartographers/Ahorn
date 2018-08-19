module TheoCrystal

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Theo Crystal" => Ahorn.EntityPlacement(
        Maple.TheoCrystal
    )
)

function selection(entity::Maple.Entity)
    if entity.name == "theoCrystal"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 10, y - 20, 20, 20)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "theoCrystal"
        Ahorn.drawSprite(ctx, "characters/theoCrystal/idle00.png", 0, -10)

        return true
    end

    return false
end

end