module EverestChangeInventoryTrigger

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Change Inventory (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestChangeInventoryTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.EverestChangeInventoryTrigger)
    return Dict{String, Any}(
        "inventory" => sort(Maple.inventories)
    )
end

end