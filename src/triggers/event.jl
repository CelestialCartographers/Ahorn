module EventTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Event" => Ahorn.EntityPlacement(
        Maple.EventTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Maple.Trigger)
    if trigger.name == "eventTrigger"
        return true, Dict{String, Any}(
            "event" => Maple.event_trigger_events
        )
    end
end

end