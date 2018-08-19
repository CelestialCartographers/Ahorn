module Heart

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Crystal Heart" => Ahorn.EntityPlacement(
        Maple.CrystalHeart
    ),
)

function selection(entity::Maple.Entity)
    if entity.name == "blackGem"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 8, y - 8, 16, 16)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "blackGem"
        Ahorn.drawSprite(ctx, "collectables/heartGem/0/00.png", 0, 0)

        return true
    end

    return false
end

end