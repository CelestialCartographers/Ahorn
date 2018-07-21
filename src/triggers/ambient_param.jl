module AmbientParamTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Ambient Param" => Main.EntityPlacement(
        Main.Maple.AmbientParamTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Main.Maple.Trigger)
    if trigger.name == "ambientParamTrigger"
        return true, Dict{String, Any}(
            "direction" => Main.Maple.trigger_position_modes
        )
    end
end

end