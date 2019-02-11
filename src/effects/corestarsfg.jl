module CoreStarFg

using ..Ahorn, Maple

placements = Maple.CoreStarFg

function Ahorn.canFgBg(effect::Maple.CoreStarFg)
    return true, false
end

end