module BirdNPC

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Bird NPC" => Ahorn.EntityPlacement(
        Maple.Bird
    )
)

# Values might be wrong
# -1 = left, 1 = right
modeFacingScale = Dict{String, Integer}(
    "climbingtutorial" => -1,
    "dashingtutorial" => 1,
    "dreamjumptutorial" => 1,
    "superwalljumptutorial" => -1,
    "hyperjumptutorial" => -1,
    "flyaway" => -1,
    "sleeping" => 1,
    "none" => -1
)

Ahorn.editingOptions(entity::Maple.Bird) = return Dict{String, Any}(
    "mode" => Maple.bird_npc_modes
)

sprite = "characters/bird/crow00.png"

function Ahorn.selection(entity::Maple.Bird)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.5, jy=1.0)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Bird, room::Maple.Room)
    key = lowercase(get(entity.data, "mode", "Sleeping"))
    scaleX = get(modeFacingScale, key, -1)
    
    Ahorn.drawSprite(ctx, sprite, 0, 0, sx=scaleX, jx=0.5, jy=1.0)
end

end