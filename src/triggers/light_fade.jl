module LightFadeTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Light Fade" => Ahorn.EntityPlacement(
        Maple.LightFadeTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Maple.Trigger)
    if trigger.name == "lightFadeTrigger"
        return true, Dict{String, Any}(
            "positionMode" => Maple.trigger_position_modes
        )
    end
end

end