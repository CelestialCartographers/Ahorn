module Bonfire

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Bonfire" => Ahorn.EntityPlacement(
        Maple.Bonfire,
        "point"
    )
)

Ahorn.editingOptions(entity::Maple.Bonfire) = Dict{String, Any}(
    "mode" => Maple.bonfire_modes
)

function bonfireSprite(entity::Maple.Bonfire)
    mode = lowercase(get(entity.data, "mode", "unlit"))

    if mode == "lit"
        return "objects/campfire/fire08.png"

    elseif mode == "smoking"
        return "objects/campfire/smoking04.png"

    else
        return "objects/campfire/fire00.png"
    end
end

function Ahorn.selection(entity::Maple.Bonfire)
    x, y = Ahorn.position(entity)
    sprite = bonfireSprite(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.5, jy=1.0)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Bonfire, room::Maple.Room)
    sprite = bonfireSprite(entity)

    Ahorn.drawSprite(ctx, sprite, 0, 0, jx=0.5, jy=1.0)
end

end