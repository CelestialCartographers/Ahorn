module EverestCustomNPC

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Custom NPC (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestCustomNPC
    )
)

function getSpriteName(entity::Maple.EverestCustomNPC)
    spriteName = get(entity.data, "sprite", "")

    return "characters/$(spriteName)00"
end


function Ahorn.selection(entity::Maple.EverestCustomNPC)
    x, y = Ahorn.position(entity)

    scaleX, scaleY = get(entity.data, "flipX", false) ? -1 : 1, get(entity.data, "flipY", false) ? -1 : 1

    spriteName = getSpriteName(entity)
    sprite = Ahorn.getSprite(spriteName, "Gameplay")

    if sprite.width == 0 || sprite.height == 0
        return Ahorn.Rectangle(x - 4, y - 4, 8, 8)

    else
        return Ahorn.getSpriteRectangle(spriteName, x, y, jx=0.5, jy=1.0, sx=scaleX, sy=scaleY)
    end
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.EverestCustomNPC, room::Maple.Room)
    scaleX, scaleY = get(entity.data, "flipX", false) ? -1 : 1, get(entity.data, "flipY", false) ? -1 : 1
    spriteName = getSpriteName(entity)

    Ahorn.drawSprite(ctx, spriteName, 0, 0, jx=0.5, jy=1.0, sx=scaleX, sy=scaleY)
end

end