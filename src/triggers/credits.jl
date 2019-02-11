module CreditsTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Credits" => Ahorn.EntityPlacement(
        Maple.CreditsTrigger,
        "rectangle"
    )
)

end