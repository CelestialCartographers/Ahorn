module AltMusicTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Alt Music" => Main.EntityPlacement(
        Main.Maple.AltMusicTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Main.Maple.Trigger)
    if trigger.name == "altMusicTrigger"
        return true, Dict{String, Any}(
            "track" => sort(collect(keys(Main.Maple.Songs.songs)))
        )
    end
end

end