module MusicTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Music" => Main.EntityPlacement(
        Main.Maple.MusicTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Main.Maple.Trigger)
    if trigger.name == "musicTrigger"
        return true, Dict{String, Any}(
            "track" => sort(collect(keys(Main.Maple.Songs.songs)))
        )
    end
end

end