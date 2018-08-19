module GoldenBerryCollectionTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Golden Berry Collection" => Ahorn.EntityPlacement(
        Maple.GoldenBerryCollectionTrigger,
        "rectangle"
    ),
)

end