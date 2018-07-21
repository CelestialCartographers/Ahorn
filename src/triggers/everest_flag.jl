module EverestFlagTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Flag (Everest)" => Main.EntityPlacement(
        Main.Maple.EverestFlagTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Main.Maple.Trigger)
    if trigger.name == "everest/flagTrigger"
        return true, Dict{String, Any}(
            "mode" => Main.Maple.everest_flag_trigger_modes
        )
    end
end

end