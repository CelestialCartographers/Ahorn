module NoRefillTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Refills (Disabled)" => Ahorn.EntityPlacement(
        Maple.NoRefillTrigger,
        "rectangle",
        Dict{String, Any}(
            "state" => true
        )
    ),
    "Refills (Enabled)" => Ahorn.EntityPlacement(
        Maple.NoRefillTrigger,
        "rectangle",
        Dict{String, Any}(
            "state" => false
        )
    )
)

end