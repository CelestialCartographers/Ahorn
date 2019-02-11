module ChangeRespawn

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Change Respawn" => Ahorn.EntityPlacement(
        Maple.ChangeRespawnTrigger,
        "rectangle"
    )
)

function Ahorn.nodeLimits(trigger::Maple.ChangeRespawnTrigger)
    return 0, 1
end

end