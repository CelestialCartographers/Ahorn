module CameraAdvanceTargetTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Camera Advance Target" => Main.EntityPlacement(
        Main.Maple.CameraAdvanceTargetTrigger,
        "rectangle",
        Dict{String, Any}(),
        function(trigger)
            trigger.data["nodes"] = [(Int(trigger.data["x"]) + Int(trigger.data["width"]) + 8, Int(trigger.data["y"]))]
        end
    )
)

function editingOptions(trigger::Main.Maple.Trigger)
    if trigger.name == "cameraAdvanceTargetTrigger"
        return true, Dict{String, Any}(
            "positionModeX" => Main.Maple.trigger_position_modes,
            "positionModeY" => Main.Maple.trigger_position_modes,
        )
    end
end

function nodeLimits(trigger::Main.Maple.Trigger)
    if trigger.name == "cameraAdvanceTargetTrigger"
        return true, 1, 1
    end
end

end