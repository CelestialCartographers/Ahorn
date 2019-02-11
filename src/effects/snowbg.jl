module SnowBg

using ..Ahorn, Maple

placements = Maple.SnowBg

function Ahorn.canFgBg(effect::Maple.SnowBg)
    return false, true
end

end