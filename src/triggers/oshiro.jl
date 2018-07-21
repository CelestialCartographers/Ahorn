module OshiroTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Oshiro (Spawn)" => Main.EntityPlacement(
        Main.Maple.OshiroTrigger,
        "rectangle",
        Dict{String, Any}(
            "state" => true
        )
    ),
    "Oshiro (Leave)" => Main.EntityPlacement(
        Main.Maple.OshiroTrigger,
        "rectangle",
        Dict{String, Any}(
            "state" => false
        )
    )
)

end