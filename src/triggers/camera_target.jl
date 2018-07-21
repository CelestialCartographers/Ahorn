module CameraTargetTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Camera Target" => Main.EntityPlacement(
        Main.Maple.CameraTargetTrigger,
        "rectangle",
        Dict{String, Any}(),
        function(trigger)
            trigger.data["nodes"] = [(Int(trigger.data["x"]) + Int(trigger.data["width"]) + 8, Int(trigger.data["y"]))]
        end
    )
)

function editingOptions(trigger::Main.Maple.Trigger)
    if trigger.name == "cameraTargetTrigger"
        return true, Dict{String, Any}(
            "positionMode" => Main.Maple.trigger_position_modes
        )
    end
end

function nodeLimits(trigger::Main.Maple.Trigger)
    if trigger.name == "cameraTargetTrigger"
        return true, 1, 1
    end
end

end