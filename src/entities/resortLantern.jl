module ResortLantern

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Resort Lantern" => Ahorn.EntityPlacement(
        Maple.ResortLantern
    )
)

function isLeftSide(entity::Maple.Entity, room::Maple.Room)
    x, y = Ahorn.entityTranslation(entity) .+ (0, 2)
    tx, ty = floor(Int, x / 8), floor(Int, y / 8)

    return get(room.fgTiles.data, (ty, tx + 2), '0') == '0'
end

function selection(entity::Maple.Entity)
    x, y = Ahorn.entityTranslation(entity)

    if entity.name == "resortLantern"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 9, y - 9, 18, 20)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "resortLantern"
        leftSide = isLeftSide(entity, room)

        Ahorn.drawSprite(ctx, "objects/resortLantern/holder.png", 0, 0, sx=leftSide? 1 : -1)
        Ahorn.drawSprite(ctx, "objects/resortLantern/lantern00.png", 0, 0, sx=leftSide? 1 : -1)

        return true
    end

    return false
end

end