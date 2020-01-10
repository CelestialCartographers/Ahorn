module EverestMusicLayer

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Music Layer (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestMusicLayerTrigger,
        "rectangle"
    )
)

end