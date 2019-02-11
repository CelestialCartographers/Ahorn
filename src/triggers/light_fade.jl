module LightFadeTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Light Fade" => Ahorn.EntityPlacement(
        Maple.LightFadeTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.LightFadeTrigger)
    return Dict{String, Any}(
        "positionMode" => Maple.trigger_position_modes
    )
end

end