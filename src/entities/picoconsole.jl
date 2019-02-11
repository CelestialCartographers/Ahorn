module PicoConsole

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Pico Console" => Ahorn.EntityPlacement(
        Maple.PicoConsole
    )
)

sprite = "objects/pico8Console"

function Ahorn.selection(entity::Maple.PicoConsole)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.5, jy=1.0)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.PicoConsole, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, 0, jx=0.5, jy=1.0)

end