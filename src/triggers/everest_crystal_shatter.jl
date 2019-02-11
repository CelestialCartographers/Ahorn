module EverestCrystalShatterTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Crystal Shatter (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestCrystalShatterTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.EverestCrystalShatterTrigger)
    return Dict{String, Any}(
        "mode" => Maple.everest_crystal_shatter_trigger_modes
    )
end

end