module StopBoostTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Stop Boost" => Ahorn.EntityPlacement(
        Maple.StopBoostTrigger,
        "rectangle"
    )
)

end