module BloomFadeTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Bloom Fade" => Main.EntityPlacement(
        Main.Maple.BloomFadeTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Main.Maple.Trigger)
    if trigger.name == "bloomFadeTrigger"
        return true, Dict{String, Any}(
            "positionMode" => Main.Maple.trigger_position_modes
        )
    end
end

end