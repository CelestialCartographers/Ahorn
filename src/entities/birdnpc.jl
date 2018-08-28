module BirdNPC

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
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
    "sleeping" => 1
)

function editingOptions(entity::Maple.Entity)
    if entity.name == "bird"
        return true, Dict{String, Any}(
            "mode" => Maple.bird_npc_modes
        )
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "bird"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 7, y - 12, 15, 13)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "bird"
        scaleX = modeFacingScale[lowercase(get(entity.data, "mode", "Sleeping"))]
        Ahorn.drawSprite(ctx, "characters/bird/crow00.png", 0, -12, sx=scaleX)

        return true
    end

    return false
end

end