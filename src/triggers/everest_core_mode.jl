module EverestCoreModeTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Core Mode (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestCoreModeTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.EverestCoreModeTrigger)
    return Dict{String, Any}(
        "mode" => sort(Maple.core_modes)
    )
end

end