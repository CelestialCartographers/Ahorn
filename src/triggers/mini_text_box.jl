module MiniTextBoxTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Mini Textbox" => Ahorn.EntityPlacement(
        Maple.MiniTextBoxTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.MiniTextBoxTrigger)
    return Dict{String, Any}(
        "mode" => Maple.mini_textbox_trigger_modes
    )
end

end