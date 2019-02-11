module SnowFg

using ..Ahorn, Maple

placements = Maple.SnowFg

function Ahorn.canFgBg(effect::Maple.SnowFg)
    return true, false
end

end