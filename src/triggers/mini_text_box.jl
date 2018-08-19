module MiniTextBoxTrigger

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Mini Textbox" => Ahorn.EntityPlacement(
        Maple.MiniTextBoxTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Maple.Trigger)
    if trigger.name == "minitextboxTrigger"
        return true, Dict{String, Any}(
            "mode" => Maple.mini_textbox_trigger_modes
        )
    end
end

end