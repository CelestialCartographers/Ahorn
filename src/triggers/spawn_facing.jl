module SpawnFacing

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Spawn Facing" => Ahorn.EntityPlacement(
        Maple.SpawnFacingTrigger,
        "rectangle"
    )
)

function Ahorn.editingOptions(trigger::Maple.SpawnFacingTrigger)
    return Dict{String, Any}(
        "facing" => sort(Maple.spawn_facing_trigger_facings)
    )
end

end