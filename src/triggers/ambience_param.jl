module AmbienceParamTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Ambience Param" => Ahorn.EntityPlacement(
        Maple.AmbienceParamTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.AmbienceParamTrigger)
    return Dict{String, Any}(
        "direction" => Maple.trigger_position_modes
    )
end

end