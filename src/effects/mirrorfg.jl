module MirrorFg

using ..Ahorn, Maple

placements = Maple.MirrorFg

function Ahorn.canFgBg(effect::Maple.MirrorFg)
    return true, false
end

end