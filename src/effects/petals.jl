module Petals

using ..Ahorn, Maple

placements = Maple.Petals

function Ahorn.canFgBg(effect::Maple.Petals)
    return true, true
end

end