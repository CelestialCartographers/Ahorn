module MusicFadeTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Music Fade" => Ahorn.EntityPlacement(
        Maple.MusicFadeTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Maple.Trigger)
    if trigger.name == "musicFadeTrigger"
        return true, Dict{String, Any}(
            "direction" => Maple.music_fade_trigger_directions
        )
    end
end

end