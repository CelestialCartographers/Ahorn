module DarkChaser

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Badeline Chaser" => Ahorn.EntityPlacement(
        Maple.DarkChaser
    ),

    "Badeline Chaser Barrier" => Ahorn.EntityPlacement(
        Maple.DarkChaserEnd,
        "rectangle"
    ),
)

Ahorn.minimumSize(entity::Maple.DarkChaserEnd) = 8, 8
Ahorn.resizable(entity::Maple.DarkChaserEnd) = true, true

# This sprite fits best, not perfect, thats why we have a offset here
chaserSprite = "characters/badeline/sleep00.png"

function Ahorn.selection(entity::Maple.DarkChaser)
    x, y = Ahorn.position(entity)
    
    return Ahorn.getSpriteRectangle(chaserSprite, x + 4, y, jx=0.5, jy=1.0)
end

function Ahorn.selection(entity::Maple.DarkChaserEnd)
    x, y = Ahorn.position(entity)

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))

    return Ahorn.Rectangle(x, y, width, height)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.DarkChaserEnd)
    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    Ahorn.drawRectangle(ctx, 0, 0, width, height, (0.4, 0.0, 0.4, 0.4), (0.4, 0.0, 0.4, 1.0))
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.DarkChaser) = Ahorn.drawSprite(ctx, chaserSprite, 4, 0, jx=0.5, jy=1.0)

end