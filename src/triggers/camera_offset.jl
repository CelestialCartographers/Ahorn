module CameraOffsetTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Camera Offset" => Ahorn.EntityPlacement(
        Maple.CameraOffsetTrigger,
        "rectangle"
    )
)

end