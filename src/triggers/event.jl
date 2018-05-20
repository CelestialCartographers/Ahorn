module EventTrigger

placements = Dict{String, Main.EntityPlacement}()

events = String["end_city", "end_oldsite_awake"]
for event in events
    key = "Event ($event)"
    placements[key] = Main.EntityPlacement(
        Main.Maple.EventTrigger,
        "rectangle",
        Dict{String, Any}(
            "event" => event
        )
    )
end

end