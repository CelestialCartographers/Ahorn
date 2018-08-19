module AltMusicTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Alt Music" => Ahorn.EntityPlacement(
        Maple.AltMusicTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Maple.Trigger)
    if trigger.name == "altMusicTrigger"
        return true, Dict{String, Any}(
            "track" => sort(collect(keys(Maple.Songs.songs)))
        )
    end
end

end