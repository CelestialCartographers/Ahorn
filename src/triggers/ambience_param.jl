module AmbienceParamTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Ambience Param" => Main.EntityPlacement(
        Main.Maple.AmbienceParamTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Main.Maple.Trigger)
    if trigger.name == "ambienceParamTrigger"
        return true, Dict{String, Any}(
            "direction" => Main.Maple.trigger_position_modes
        )
    end
end

end