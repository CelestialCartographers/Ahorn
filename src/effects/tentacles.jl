module TentacleEffect

using ..Ahorn, Maple

placements = Maple.TentacleEffect

function Ahorn.canFgBg(effect::Maple.TentacleEffect)
    return true, true
end

function Ahorn.editingOptions(effect::Maple.TentacleEffect)
    return Dict{String, Any}(
        "side" => Maple.tentacle_effect_directions
    )
end

end