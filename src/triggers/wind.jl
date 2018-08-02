module WindTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Wind Pattern" => Main.EntityPlacement(
        Main.Maple.WindTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Main.Maple.Trigger)
    if trigger.name == "windTrigger"
        return true, Dict{String, Any}(
            "pattern" => patterns
        )
    end
end

end