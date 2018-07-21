module NoRefillTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Refills (Disabled)" => Main.EntityPlacement(
        Main.Maple.NoRefillTrigger,
        "rectangle",
        Dict{String, Any}(
            "state" => true
        )
    ),
    "Refills (Enabled)" => Main.EntityPlacement(
        Main.Maple.NoRefillTrigger,
        "rectangle",
        Dict{String, Any}(
            "state" => false
        )
    )
)

end