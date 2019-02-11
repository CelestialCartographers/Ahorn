module EverestLavaBlockerTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Lava Blocker (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestLavaBlockerTrigger,
        "rectangle"
    )
)

end