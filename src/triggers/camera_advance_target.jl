module CameraAdvanceTargetTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Camera Advance Target" => Ahorn.EntityPlacement(
        Maple.CameraAdvanceTargetTrigger,
        "rectangle",
        Dict{String, Any}(),
        function(trigger)
            trigger.data["nodes"] = [(Int(trigger.data["x"]) + Int(trigger.data["width"]) + 8, Int(trigger.data["y"]))]
        end
    )
)

function editingOptions(trigger::Maple.Trigger)
    if trigger.name == "cameraAdvanceTargetTrigger"
        return true, Dict{String, Any}(
            "positionModeX" => Maple.trigger_position_modes,
            "positionModeY" => Maple.trigger_position_modes,
        )
    end
end

function nodeLimits(trigger::Maple.Trigger)
    if trigger.name == "cameraAdvanceTargetTrigger"
        return true, 1, 1
    end
end

end