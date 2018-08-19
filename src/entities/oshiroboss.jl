module OshiroBoss

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Oshiro Boss" => Ahorn.EntityPlacement(
        Maple.FriendlyGhost
    )
)

function selection(entity::Maple.Entity)
    if entity.name == "friendlyGhost"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 15, y - 16, 30, 40)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "friendlyGhost"
        Ahorn.drawSprite(ctx, "characters/oshiro/boss13.png", 0, 0)

        return true
    end

    return false
end

end