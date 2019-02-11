module WhiteBlock

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "White Block" => Ahorn.EntityPlacement(
        Maple.WhiteBlock
    )
)

sprite = "objects/whiteblock.png"

function Ahorn.selection(entity::Maple.WhiteBlock)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.0, jy=0.0)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.WhiteBlock, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, 0, jx=0.0, jy=0.0)

end