module DetachFollowersTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Detach Followers" => Ahorn.EntityPlacement(
        Maple.DetachFollowersTrigger,
        "rectangle",
        Dict{String, Any}(),
        function(trigger)
            trigger.data["nodes"] = [
                (Int(trigger.data["x"]) + Int(trigger.data["width"]) + 8, Int(trigger.data["y"])),
            ]
        end
    )
)

function Ahorn.nodeLimits(trigger::Maple.DetachFollowersTrigger)
    return 1, 1
end

end