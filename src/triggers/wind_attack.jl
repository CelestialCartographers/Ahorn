module WindAttackTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Snowballs" => Ahorn.EntityPlacement(
        Maple.WindAttackTrigger,
        "rectangle",
    ),
)

end