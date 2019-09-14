module BlackHoleStrengthTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Black Hole Strength" => Ahorn.EntityPlacement(
        Maple.BlackHoleStrengthTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.BlackHoleStrengthTrigger)
    return Dict{String, Any}(
        "strength" => Maple.black_hole_trigger_strengths
    )
end

end