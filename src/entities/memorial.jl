module Memorial

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Memorial" => Ahorn.EntityPlacement(
        Maple.Memorial
    ),
    "Custom Memorial (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestMemorial
    )
)

sprite = "scenery/memorial/memorial"

function Ahorn.selection(entity::Maple.Memorial)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.5, jy=1.0)
end

function Ahorn.selection(entity::Maple.EverestMemorial)
    x, y = Ahorn.position(entity)

    spriteName = get(entity.data, "sprite", sprite)
    customSprite = Ahorn.getSprite(spriteName, "Gameplay")

    if customSprite.width == 0 || customSprite.height == 0
        return Ahorn.Rectangle(x - 4, y - 4, 8, 8)

    else
        return Ahorn.getSpriteRectangle(spriteName, x, y, jx=0.5, jy=1.0)
    end
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.EverestMemorial, room::Maple.Room)
    spriteName = get(entity.data, "sprite", sprite)

    Ahorn.drawSprite(ctx, spriteName, 0, 0, jx=0.5, jy=1.0)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Memorial, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, 0, jx=0.5, jy=1.0)

end