module CreditsTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Credits" => Ahorn.EntityPlacement(
        Maple.CreditsTrigger,
        "rectangle"
    )
)

end