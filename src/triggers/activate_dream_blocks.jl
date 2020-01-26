module ActivateDreamBlocks

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Activate Space Jams" => Ahorn.EntityPlacement(
        Maple.ActivateDreamBlocks,
        "rectangle"
    )
)

end