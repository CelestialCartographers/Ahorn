module WhiteBlock

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "White Block" => Ahorn.EntityPlacement(
        Maple.WhiteBlock
    )
)

function selection(entity::Maple.Entity)
    if entity.name == "whiteblock"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x, y, 48, 24)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "whiteblock"
        Ahorn.drawSprite(ctx, "objects/whiteblock.png", 24, 12)

        return true
    end

    return false
end

end