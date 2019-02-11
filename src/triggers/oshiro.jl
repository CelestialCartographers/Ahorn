module OshiroTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
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