module CheckpointBlocker

placements = Dict{String, Main.EntityPlacement}(
    "Checkpoint Blocker" => Main.EntityPlacement(
        Main.Maple.CheckpointBlockerTrigger,
        "rectangle"
    )
)

end