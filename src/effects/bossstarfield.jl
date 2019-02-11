module BossStarField

using ..Ahorn, Maple

placements = Maple.BossStarField

function Ahorn.canFgBg(effect::Maple.BossStarField)
    return true, true
end

end