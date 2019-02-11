module RespawnTargetTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Respawn Target" => Ahorn.EntityPlacement(
        Maple.RespawnTargetTrigger,
        "rectangle",
        Dict{String, Any}(),
        function(trigger)
            trigger.data["nodes"] = [(Int(trigger.data["x"]) + Int(trigger.data["width"]) + 8, Int(trigger.data["y"]))]
        end
    )
)

function Ahorn.nodeLimits(trigger::Maple.RespawnTargetTrigger)
    return 1, 1
end

end