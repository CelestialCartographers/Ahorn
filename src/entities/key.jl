module Key

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Key" => Ahorn.EntityPlacement(
        Maple.Key
    ),
)

function selection(entity::Maple.Entity)
    if entity.name == "key"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 8, y - 8, 16, 16)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "key"
        Ahorn.drawSprite(ctx, "collectables/key/idle00.png", 0, 0)

        return true
    end

    return false
end

end