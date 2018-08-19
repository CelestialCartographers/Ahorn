module LookoutBlocker

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Lookout Blocker" => Ahorn.EntityPlacement(
        Maple.LookoutBlocker,
        "rectangle"
    )
)

end