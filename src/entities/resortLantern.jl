module ResortLantern

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Resort Lantern" => Ahorn.EntityPlacement(
        Maple.ResortLantern
    )
)

holderSprite = "objects/resortLantern/holder.png"
lanternSprite = "objects/resortLantern/lantern00.png"

function isLeftSide(entity::Maple.ResortLantern, room::Maple.Room)
    x, y = Ahorn.position(entity) .+ (0, 2)
    tx, ty = floor(Int, x / 8), floor(Int, y / 8)

    return get(room.fgTiles.data, (ty, tx + 2), '0') == '0'
end

function Ahorn.selection(entity::Maple.ResortLantern, room::Maple.Room)
    x, y = Ahorn.position(entity)

    leftSide = isLeftSide(entity, room)

    return Ahorn.coverRectangles([
        Ahorn.getSpriteRectangle(holderSprite, x, y, sx=leftSide ? 1 : -1),
        Ahorn.getSpriteRectangle(lanternSprite, x, y)
    ])
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.ResortLantern, room::Maple.Room)
    leftSide = isLeftSide(entity, room)

    Ahorn.drawSprite(ctx, holderSprite, 0, 0, sx=leftSide ? 1 : -1)
    Ahorn.drawSprite(ctx, lanternSprite, 0, 0)
end

end