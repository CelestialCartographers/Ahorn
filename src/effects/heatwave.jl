module Heatwave

using ..Ahorn, Maple

placements = Maple.Heatwave

function Ahorn.canFgBg(effect::Maple.Heatwave)
    return true, true
end

end