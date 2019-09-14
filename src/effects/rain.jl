module Rain

using ..Ahorn, Maple

placements = Maple.Rain

function Ahorn.canFgBg(effect::Maple.Rain)
    return true, true
end

end