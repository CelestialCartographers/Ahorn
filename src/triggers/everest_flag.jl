module EverestFlagTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Flag (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestFlagTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Maple.Trigger)
    if trigger.name == "everest/flagTrigger"
        return true, Dict{String, Any}(
            "mode" => Maple.everest_flag_trigger_modes
        )
    end
end

end