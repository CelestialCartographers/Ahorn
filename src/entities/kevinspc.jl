module KevinsPC

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Kevin's PC" => Ahorn.EntityPlacement(
        Maple.KevinsPC
    )
)

spritePC = "objects/kevinspc/pc"
spriteSpectogram = "objects/kevinspc/spectogram"

# We don't need the back texture, it fits inside
function Ahorn.selection(entity::Maple.KevinsPC)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(spritePC, x, y, jx=0.5, jy=1.0)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.KevinsPC, room::Maple.Room)
    Ahorn.drawSprite(ctx, spritePC, 0, 0, jx=0.5, jy=1.0)
    Ahorn.drawImage(ctx, spriteSpectogram, -16, -39, 0, 0, 32, 18)
end

end