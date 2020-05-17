module ForegroundDebris

using ..Ahorn, Maple
using Random

const placements = Ahorn.PlacementDict(
    "Foreground Debris" => Ahorn.EntityPlacement(
        Maple.ForegroundDebris
    )
)

const rockTextures = Dict{String, Array{String, 1}}(
    "rock_a" => [
        "scenery/fgdebris/rock_a00",
        "scenery/fgdebris/rock_a01",
        "scenery/fgdebris/rock_a02"
    ],
    "rock_b" => [
        "scenery/fgdebris/rock_b00",
        "scenery/fgdebris/rock_b01"
    ]
)

function Ahorn.selection(entity::Maple.ForegroundDebris)
    x, y = Ahorn.position(entity)
        
    return Ahorn.Rectangle(x - 24, y - 24, 48, 48)
end

# Blame parallax for rendering being offset
function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.ForegroundDebris, room::Maple.Room)
    rng = Ahorn.getSimpleEntityRng(entity)
    key = rand(rng, keys(rockTextures))

    for texture in rockTextures[key]
        Ahorn.drawSprite(ctx, texture, 0, 0)
    end
end

end