module StopBoostTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Stop Boost" => Ahorn.EntityPlacement(
        Maple.StopBoostTrigger,
        "rectangle"
    )
)

end