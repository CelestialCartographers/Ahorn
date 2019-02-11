module WindTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Wind Pattern" => Ahorn.EntityPlacement(
        Maple.WindTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.WindTrigger)
    return Dict{String, Any}(
        "pattern" => Maple.wind_patterns
    )
end

end