module Starfield

using ..Ahorn, Maple

placements = Maple.Starfield

function Ahorn.canFgBg(effect::Maple.Starfield)
    return true, true
end

end