module CameraOffsetTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Camera Offset" => Ahorn.EntityPlacement(
        Maple.CameraOffsetTrigger,
        "rectangle"
    )
)

end