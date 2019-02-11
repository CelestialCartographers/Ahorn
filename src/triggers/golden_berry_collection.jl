module GoldenBerryCollectionTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Golden Berry Collection" => Ahorn.EntityPlacement(
        Maple.GoldenBerryCollectionTrigger,
        "rectangle"
    ),
)

end