module EverestCustomBirdTutorialTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Custom Bird Tutorial (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestCustomBirdTutorialTrigger,
        "rectangle"
    )
)

end