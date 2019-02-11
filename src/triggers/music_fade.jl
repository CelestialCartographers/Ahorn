module MusicFadeTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Music Fade" => Ahorn.EntityPlacement(
        Maple.MusicFadeTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.MusicFadeTrigger)
    return Dict{String, Any}(
        "direction" => Maple.music_fade_trigger_directions
    )
end

end