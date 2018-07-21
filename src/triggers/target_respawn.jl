module RespawnTargetTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Respawn Target" => Main.EntityPlacement(
        Main.Maple.RespawnTargetTrigger,
        "rectangle",
        Dict{String, Any}(),
        function(trigger)
            trigger.data["nodes"] = [(Int(trigger.data["x"]) + Int(trigger.data["width"]) + 8, Int(trigger.data["y"]))]
        end
    )
)

function nodeLimits(trigger::Main.Maple.Trigger)
    if trigger.name == "respawnTargetTrigger"
        return true, 1, 1
    end
end

end