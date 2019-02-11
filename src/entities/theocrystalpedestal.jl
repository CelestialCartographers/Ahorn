module TheoCrystalPedestal

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Theo Crystal Pedestal" => Ahorn.EntityPlacement(
        Maple.TheoCrystalPedestal
    )
)

sprite = "characters/theoCrystal/pedestal.png"

function Ahorn.selection(entity::Maple.TheoCrystalPedestal)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.5, jy=1.0)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.TheoCrystalPedestal, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, 0, jx=0.5, jy=1.0)

end