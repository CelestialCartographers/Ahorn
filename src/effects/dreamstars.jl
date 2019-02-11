module DreamStars

using ..Ahorn, Maple

placements = Maple.DreamStars

function Ahorn.canFgBg(effect::Maple.DreamStars)
    return true, true
end

end