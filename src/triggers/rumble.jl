module RumbleTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Rumble" => Ahorn.EntityPlacement(
        Maple.RumbleTrigger,
        "rectangle",
        Dict{String, Any}(),
        function(trigger)
            trigger.data["nodes"] = [
                (Int(trigger.data["x"]) + Int(trigger.data["width"]) + 8, Int(trigger.data["y"])),
                (Int(trigger.data["x"]) + Int(trigger.data["width"]) + 16, Int(trigger.data["y"]))
            ]
        end
    )
)

function Ahorn.nodeLimits(trigger::Maple.RumbleTrigger)
    return 2, 2
end

end