module MiniTextBoxTrigger

placements = Dict{String, Main.EntityPlacement}(
    "Mini Textbox" => Main.EntityPlacement(
        Main.Maple.MiniTextBoxTrigger,
        "rectangle"
    )
)

function editingOptions(trigger::Main.Maple.Trigger)
    if trigger.name == "minitextboxTrigger"
        return true, Dict{String, Any}(
            "mode" => Main.Maple.mini_textbox_trigger_modes
        )
    end
end

end