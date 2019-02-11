module GodRays

using ..Ahorn, Maple

placements = Maple.GodRays

function Ahorn.canFgBg(effect::Maple.GodRays)
    return true, true
end

end