module EverestDialogCutsceneTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Dialog Cutscene (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestDialogTrigger,
        "rectangle"
    )
)

end