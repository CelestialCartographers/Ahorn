module MusicTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Music" => Ahorn.EntityPlacement(
        Maple.MusicTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Maple.Trigger)
    if trigger.name == "musicTrigger"
        return true, Dict{String, Any}(
            "track" => sort(collect(keys(Maple.Songs.songs)))
        )
    end
end

end