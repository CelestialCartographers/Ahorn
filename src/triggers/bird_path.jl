module BirdPathTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Bird Path" => Ahorn.EntityPlacement(
        Maple.BirdPathTrigger,
        "rectangle"
    )
)

end