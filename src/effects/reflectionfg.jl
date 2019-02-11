module ReflectionFg

using ..Ahorn, Maple

placements = Maple.ReflectionFg

function Ahorn.canFgBg(effect::Maple.ReflectionFg)
    return true, false
end

end