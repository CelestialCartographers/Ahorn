module StarDust

using ..Ahorn, Maple

placements = Maple.StarDust

function Ahorn.canFgBg(effect::Maple.StarDust)
    return true, true
end

end