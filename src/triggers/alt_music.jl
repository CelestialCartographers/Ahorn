module AltMusicTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Alt Music" => Ahorn.EntityPlacement(
        Maple.AltMusicTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.AltMusicTrigger)
    return Dict{String, Any}(
        "track" => sort(collect(keys(Maple.Songs.songs)))
    )
end

end