module CheckpointBlocker

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Checkpoint Blocker" => Ahorn.EntityPlacement(
        Maple.CheckpointBlockerTrigger,
        "rectangle"
    )
)

end