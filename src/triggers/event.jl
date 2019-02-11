module EventTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Event" => Ahorn.EntityPlacement(
        Maple.EventTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.EventTrigger)
    return Dict{String, Any}(
        "event" => Maple.event_trigger_events
    )
end

end