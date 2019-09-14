module InternetCafe

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Internet Café" => Ahorn.EntityPlacement(
        Maple.InternetCafe
    )
)

spriteBack = "objects/wavedashtutorial/building_back"
spriteLeft = "objects/wavedashtutorial/building_front_left"
spriteRight = "objects/wavedashtutorial/building_front_right"

# We don't need the back texture, it fits inside
function Ahorn.selection(entity::Maple.InternetCafe)
    x, y = Ahorn.position(entity)

    return Ahorn.coverRectangles([
        Ahorn.getSpriteRectangle(spriteLeft, x, y, jx=0.5, jy=1.0),
        Ahorn.getSpriteRectangle(spriteRight, x, y, jx=0.5, jy=1.0),
    ])
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.InternetCafe, room::Maple.Room)
    Ahorn.drawSprite(ctx, spriteBack, 0, 0, jx=0.5, jy=1.0)
    Ahorn.drawSprite(ctx, spriteLeft, 0, 0, jx=0.5, jy=1.0)
    Ahorn.drawSprite(ctx, spriteRight, 0, 0, jx=0.5, jy=1.0)
end

end