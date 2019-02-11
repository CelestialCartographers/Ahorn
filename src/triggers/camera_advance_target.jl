module CameraAdvanceTargetTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Camera Advance Target" => Ahorn.EntityPlacement(
        Maple.CameraAdvanceTargetTrigger,
        "rectangle",
        Dict{String, Any}(),
        function(trigger)
            trigger.data["nodes"] = [(Int(trigger.data["x"]) + Int(trigger.data["width"]) + 8, Int(trigger.data["y"]))]
        end
    )
)

function Ahorn.editingOptions(trigger::Maple.CameraAdvanceTargetTrigger)
    return Dict{String, Any}(
        "positionModeX" => Maple.trigger_position_modes,
        "positionModeY" => Maple.trigger_position_modes,
    )
end

function Ahorn.nodeLimits(trigger::Maple.CameraAdvanceTargetTrigger)
    return 1, 1
end

end