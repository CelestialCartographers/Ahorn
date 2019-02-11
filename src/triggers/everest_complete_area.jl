module EverestCompleteAreaTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Complete Area (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestCompleteAreaTrigger,
        "rectangle"
    )
)

end