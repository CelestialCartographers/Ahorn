module EverestCustomBirdTutorial

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Custom Bird Tutorial (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestCustomBird
    )
)

Ahorn.nodeLimits(entity::Maple.EverestCustomBird) = 0, -1

Ahorn.editingOptions(entity::Maple.EverestCustomBird) = return Dict{String, Any}(
    "info" => Maple.everest_bird_tutorial_tutorials
)

sprite = "characters/bird/crow00"

function Ahorn.selection(entity::Maple.EverestCustomBird)
    x, y = Ahorn.position(entity)
    scaleX = get(entity.data, "faceLeft", true) ? -1 : 1

    return Ahorn.getSpriteRectangle(sprite, x, y, sx=scaleX, jx=0.5, jy=1.0)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.EverestCustomBird, room::Maple.Room)
    scaleX = get(entity.data, "faceLeft", true) ? -1 : 1
    
    Ahorn.drawSprite(ctx, sprite, 0, 0, sx=scaleX, jx=0.5, jy=1.0)
end

end