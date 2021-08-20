module ActivateDreamBlocks

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Activate Space Jams (Everest)" => Ahorn.EntityPlacement(
        Maple.ActivateDreamBlocksTrigger,
        "rectangle"
    )
)

end