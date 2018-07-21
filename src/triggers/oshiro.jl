module OshiroTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Oshiro (Angry)" => Main.EntityPlacement(
        Main.Maple.OshiroTrigger,
        "rectangle",
        Dict{String, Any}(
            "state" => true
        )
    ),
    "Oshiro (Happy)" => Main.EntityPlacement(
        Main.Maple.OshiroTrigger,
        "rectangle",
        Dict{String, Any}(
            "state" => false
        )
    )
)

end