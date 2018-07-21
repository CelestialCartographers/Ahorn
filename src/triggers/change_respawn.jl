module ChangeRespawn

placements = Dict{String, Main.EntityPlacement}(
    "Change Respawn" => Main.EntityPlacement(
        Main.Maple.ChangeRespawnTrigger,
        "rectangle"
    )
)

function nodeLimits(trigger::Main.Maple.Trigger)
    if trigger.name == "changeRespawnTrigger"
        return true, 0, 1
    end
end

end