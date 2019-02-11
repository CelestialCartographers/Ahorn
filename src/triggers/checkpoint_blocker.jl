module CheckpointBlocker

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Checkpoint Blocker" => Ahorn.EntityPlacement(
        Maple.CheckpointBlockerTrigger,
        "rectangle"
    )
)

end