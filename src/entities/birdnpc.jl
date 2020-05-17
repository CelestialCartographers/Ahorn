module BirdNPC

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Bird NPC" => Ahorn.EntityPlacement(
        Maple.Bird
    )
)

# Values might be wrong
# -1 = left, 1 = right
const modeFacingScale = Dict{String, Integer}(
    "climbingtutorial" => -1,
    "dashingtutorial" => 1,
    "dreamjumptutorial" => 1,
    "superwalljumptutorial" => -1,
    "hyperjumptutorial" => -1,
    "movetonodes" => -1,
    "waitforlightningoff" => -1,
    "flyaway" => -1,
    "sleeping" => 1,
    "none" => -1
)

Ahorn.nodeLimits(entity::Maple.Bird) = 0, -1

Ahorn.editingOptions(entity::Maple.Bird) = return Dict{String, Any}(
    "mode" => Maple.bird_npc_modes
)

sprite = "characters/bird/crow00"

function Ahorn.selection(entity::Maple.Bird)
    nodes = get(entity.data, "nodes", ())
    x, y = Ahorn.position(entity)
    key = lowercase(get(entity.data, "mode", "Sleeping"))
    scaleX = get(modeFacingScale, key, -1)

    res = Ahorn.Rectangle[Ahorn.getSpriteRectangle(sprite, x, y, sx=scaleX, jx=0.5, jy=1.0)]
    
    for node in nodes
        nx, ny = Int.(node)

        push!(res, Ahorn.getSpriteRectangle(sprite, nx, ny, sx=scaleX, jx=0.5, jy=1.0))
    end

    return res
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Bird)
    px, py = Ahorn.position(entity)
    key = lowercase(get(entity.data, "mode", "Sleeping"))
    scaleX = get(modeFacingScale, key, -1)

    for node in get(entity.data, "nodes", ())
        nx, ny = Int.(node)

        theta = atan(py - ny, px - nx)
        Ahorn.drawArrow(ctx, px, py - 8, nx + cos(theta) * 8, ny + sin(theta) * 8 - 8, Ahorn.colors.selection_selected_fc, headLength=6)
        Ahorn.drawSprite(ctx, sprite, nx, ny, sx=scaleX, jx=0.5, jy=1.0)

        px, py = nx, ny
    end
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Bird, room::Maple.Room)
    key = lowercase(get(entity.data, "mode", "Sleeping"))
    scaleX = get(modeFacingScale, key, -1)
    
    Ahorn.drawSprite(ctx, sprite, 0, 0, sx=scaleX, jx=0.5, jy=1.0)
end

end