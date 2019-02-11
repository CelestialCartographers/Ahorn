module LookoutBlocker

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Lookout Blocker" => Ahorn.EntityPlacement(
        Maple.LookoutBlocker,
        "rectangle"
    )
)

end