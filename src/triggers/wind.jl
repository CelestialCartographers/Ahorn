module WindTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Wind Pattern" => Ahorn.EntityPlacement(
        Maple.WindTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Maple.Trigger)
    if trigger.name == "windTrigger"
        return true, Dict{String, Any}(
            "pattern" => Maple.wind_patterns
        )
    end
end

end