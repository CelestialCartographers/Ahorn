module CliffsideFlag

using ..Ahorn, Maple

validFlagIndicdes = collect(0:10)

const placements = Ahorn.PlacementDict(
    "Cliffside Big Flag" => Ahorn.EntityPlacement(
        Maple.CliffsideFlag,
    )
)

Ahorn.editingOptions(entity::Maple.CliffsideFlag) = Dict{String, Any}(
    "index" => validFlagIndicdes
)

function flagSprite(entity::Maple.CliffsideFlag)
    index = Int(get(entity.data, "index", 0))
    lookup = lpad(string(index), 2, "0")

    return "scenery/cliffside/flag$(lookup)"
end

function Ahorn.selection(entity::Maple.CliffsideFlag)
    x, y = Ahorn.position(entity)
    sprite = flagSprite(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.0, jy=0.0)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.CliffsideFlag, room::Maple.Room)
    sprite = flagSprite(entity)
    Ahorn.drawSprite(ctx, sprite, 0, 0, jx=0.0, jy=0.0)
end

end