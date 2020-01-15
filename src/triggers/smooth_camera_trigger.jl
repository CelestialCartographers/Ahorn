module EverestSmoothCameraOffsetTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Smooth Camera Offset (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestSmoothCameraOffsetTrigger,
        "rectangle"
    ),
)

function Ahorn.editingOptions(trigger::Maple.EverestSmoothCameraOffsetTrigger)
    return Dict{String, Any}(
        "positionMode" => Maple.trigger_position_modes
    )
end

end