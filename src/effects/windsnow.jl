module Wind

using ..Ahorn, Maple

placements = Maple.Wind

function Ahorn.canFgBg(effect::Maple.Wind)
    return true, true
end

end