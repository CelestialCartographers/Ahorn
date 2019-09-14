module MoonGlitchBackgroundTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Moon Glitch Background" => Ahorn.EntityPlacement(
        Maple.MoonGlitchBackgroundTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.MoonGlitchBackgroundTrigger)
    return Dict{String, Any}(
        "duration" => Maple.moon_glitch_background_trigger_durations
    )
end

end