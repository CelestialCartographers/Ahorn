module WindAttackTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Snowballs" => Ahorn.EntityPlacement(
        Maple.WindAttackTrigger,
        "rectangle",
    ),
)

end