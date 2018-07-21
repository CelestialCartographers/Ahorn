module LightFadeTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Light Fade" => Main.EntityPlacement(
        Main.Maple.LightFadeTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Main.Maple.Trigger)
    if trigger.name == "lightFadeTrigger"
        return true, Dict{String, Any}(
            "positionMode" => Main.Maple.trigger_position_modes
        )
    end
end

end