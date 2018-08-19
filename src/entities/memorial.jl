module Memorial

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Memorial" => Ahorn.EntityPlacement(
        Maple.Memorial
    )
)

function selection(entity::Maple.Entity)
    if entity.name == "memorial"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 20, y - 60, 40, 60)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "memorial"
        Ahorn.drawSprite(ctx, "scenery/memorial/memorial.png", 0, -32)

        return true
    end

    return false
end

end