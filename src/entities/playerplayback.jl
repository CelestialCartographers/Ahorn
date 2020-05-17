module PlayerPlayback

using ..Ahorn, Maple

# Read from disk instead?
const baseGameTutorials = String[
    "combo", "superwalljump", "too_close", "too_far",
    "wavedash", "wavedashppt"
]

const placements = Ahorn.PlacementDict(
    "Ghost Player Playback" => Ahorn.EntityPlacement(
        Maple.PlayerPlayback
    )
)

Ahorn.editingOptions(entity::Maple.PlayerPlayback) = Dict{String, Any}(
    "tutorial" => baseGameTutorials
)

Ahorn.nodeLimits(entity::Maple.PlayerPlayback) = 0, 2

const sprite = "characters/player/sitDown00"
const tint = (0.8, 0.2, 0.2, 0.75)

function Ahorn.selection(entity::Maple.PlayerPlayback)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.5, jy=1.0)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.PlayerPlayback) = Ahorn.drawSprite(ctx, sprite, 0, 0, jx=0.5, jy=1.0, tint=tint)

end