module BlackHole

using ..Ahorn, Maple

placements = Maple.BlackHole

function Ahorn.canFgBg(effect::Maple.BlackHole)
    return true, true
end

end