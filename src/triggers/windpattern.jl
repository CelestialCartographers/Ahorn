module WindPatternTrigger

placements = Dict{String, Main.EntityPlacement}()

patterns = Main.Maple.windpatterns
for pattern in patterns
    key = "Wind Pattern ($(titlecase(pattern)))"
    placements[key] = Main.EntityPlacement(
        Main.Maple.WindTrigger,
        "rectangle",
        Dict{String, Any}(
            "pattern" => pattern,
        )
    )
end

end