module MusicFadeTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Music Fade" => Main.EntityPlacement(
        Main.Maple.MusicFadeTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Main.Maple.Trigger)
    if trigger.name == "musicFadeTrigger"
        return true, Dict{String, Any}(
            "direction" => Main.Maple.music_fade_trigger_directions
        )
    end
end

end