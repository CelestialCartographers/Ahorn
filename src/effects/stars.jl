module Stars

using ..Ahorn, Maple

placements = Maple.Stars

function Ahorn.canFgBg(effect::Maple.Stars)
    return true, true
end

end