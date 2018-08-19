module AmbienceParamTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Ambience Param" => Ahorn.EntityPlacement(
        Maple.AmbienceParamTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Maple.Trigger)
    if trigger.name == "ambienceParamTrigger"
        return true, Dict{String, Any}(
            "direction" => Maple.trigger_position_modes
        )
    end
end

end