module Player

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Player" => Ahorn.EntityPlacement(
        Maple.Player
    )
)

function selection(entity::Maple.Entity)
    if entity.name == "player"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 7, y - 16, 12, 16)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity)
    if entity.name == "player"
        Ahorn.drawSprite(ctx, "characters/player/sitDown00.png", 0, -16)

        return true
    end
end

end