module EverestCustomHeightDisplay

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Custom Height Display (Everest)" => Ahorn.EntityPlacement(
        Maple.CustomHeightDisplayTrigger,
        "rectangle"
    )
)

end