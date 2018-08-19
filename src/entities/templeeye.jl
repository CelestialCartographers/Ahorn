module TempleEye

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Temple Eye (Small)" => Ahorn.EntityPlacement(
        Maple.TempleEye
    )
)

function selection(entity::Maple.Entity)
    if entity.name == "templeEye"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 6, y - 6, 12, 12)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "templeEye"
        x, y = Ahorn.entityTranslation(entity)
        tx, ty = floor(Int, x / 8) + 1, floor(Int, y / 8) + 1

        version = get(room.fgTiles.data, (ty, tx), '0') == '0'? "bg" : "fg"
        Ahorn.drawSprite(ctx, "scenery/temple/eye/$(version)_eye.png", 0, 0)
        Ahorn.drawSprite(ctx, "scenery/temple/eye/$(version)_lid00.png", 0, 0)
        Ahorn.drawSprite(ctx, "scenery/temple/eye/$(version)_pupil.png", 0, 0)

        return true
    end

    return false
end

end