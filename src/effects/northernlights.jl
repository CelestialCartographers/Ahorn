module NorthernLights

using ..Ahorn, Maple

placements = Maple.NorthernLights

function Ahorn.canFgBg(effect::Maple.NorthernLights)
    return true, true
end

end