module OshiroTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Oshiro (Spawn)" => Ahorn.EntityPlacement(
        Maple.OshiroTrigger,
        "rectangle",
        Dict{String, Any}(
            "state" => true
        )
    ),
    "Oshiro (Leave)" => Ahorn.EntityPlacement(
        Maple.OshiroTrigger,
        "rectangle",
        Dict{String, Any}(
            "state" => false
        )
    )
)

end