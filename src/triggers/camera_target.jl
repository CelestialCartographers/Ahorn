module CameraTargetTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Camera Target" => Ahorn.EntityPlacement(
        Maple.CameraTargetTrigger,
        "rectangle",
        Dict{String, Any}(),
        function(trigger)
            trigger.data["nodes"] = [(Int(trigger.data["x"]) + Int(trigger.data["width"]) + 8, Int(trigger.data["y"]))]
        end
    )
)

function Ahorn.editingOptions(trigger::Maple.CameraTargetTrigger)
    return Dict{String, Any}(
        "positionMode" => Maple.trigger_position_modes
    )
end

function Ahorn.nodeLimits(trigger::Maple.CameraTargetTrigger)
    return 1, 1
end

end