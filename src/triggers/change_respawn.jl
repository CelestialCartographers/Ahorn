module ChangeRespawn

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Change Respawn" => Ahorn.EntityPlacement(
        Maple.ChangeRespawnTrigger,
        "rectangle"
    )
)

function nodeLimits(trigger::Maple.Trigger)
    if trigger.name == "changeRespawnTrigger"
        return true, 0, 1
    end
end

end