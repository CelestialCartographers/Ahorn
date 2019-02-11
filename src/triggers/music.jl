module MusicTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Music" => Ahorn.EntityPlacement(
        Maple.MusicTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.MusicTrigger)
    return Dict{String, Any}(
        "track" => sort(collect(keys(Maple.Songs.songs)))
    )
end

end