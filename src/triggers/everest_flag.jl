module EverestFlagTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Flag (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestFlagTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.EverestFlagTrigger)
    return Dict{String, Any}(
        "mode" => Maple.everest_flag_trigger_modes
    )
end

end