module BloomFadeTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Bloom Fade" => Ahorn.EntityPlacement(
        Maple.BloomFadeTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.BloomFadeTrigger)
    return Dict{String, Any}(
        "positionMode" => Maple.trigger_position_modes
    )
end

end