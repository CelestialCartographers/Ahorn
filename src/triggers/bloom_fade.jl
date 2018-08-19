module BloomFadeTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Bloom Fade" => Ahorn.EntityPlacement(
        Maple.BloomFadeTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Maple.Trigger)
    if trigger.name == "bloomFadeTrigger"
        return true, Dict{String, Any}(
            "positionMode" => Maple.trigger_position_modes
        )
    end
end

end