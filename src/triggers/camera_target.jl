module CameraTargetTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Camera Target" => Ahorn.EntityPlacement(
        Maple.CameraTargetTrigger,
        "rectangle",
        Dict{String, Any}(),
        function(trigger)
            trigger.data["nodes"] = [(Int(trigger.data["x"]) + Int(trigger.data["width"]) + 8, Int(trigger.data["y"]))]
        end
    )
)

function editingOptions(trigger::Maple.Trigger)
    if trigger.name == "cameraTargetTrigger"
        return true, Dict{String, Any}(
            "positionMode" => Maple.trigger_position_modes
        )
    end
end

function nodeLimits(trigger::Maple.Trigger)
    if trigger.name == "cameraTargetTrigger"
        return true, 1, 1
    end
end

end