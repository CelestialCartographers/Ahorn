module Planets

using ..Ahorn, Maple

placements = Maple.Planets

function Ahorn.editingOptions(effect::Maple.Planets)
    return Dict{String, Any}(
        "size" => Maple.planet_effect_sizes
    )
end

function Ahorn.canFgBg(effect::Maple.Planets)
    return true, true
end

end