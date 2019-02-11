module NoRefillTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
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