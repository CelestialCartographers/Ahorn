module TempleEye

placements = Dict{String, Main.EntityPlacement}(
    "Temple Eye (Small)" => Main.EntityPlacement(
        Main.Maple.TempleEye
    )
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "templeEye"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 6, y - 6, 12, 12)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "templeEye"
        x, y = Main.entityTranslation(entity)
        tx, ty = floor(Int, x / 8) + 1, floor(Int, y / 8) + 1

        version = get(room.fgTiles.data, (ty, tx), '0') == '0'? "bg" : "fg"
        Main.drawSprite(ctx, "scenery/temple/eye/$(version)_eye.png", 0, 0)
        Main.drawSprite(ctx, "scenery/temple/eye/$(version)_lid00.png", 0, 0)
        Main.drawSprite(ctx, "scenery/temple/eye/$(version)_pupil.png", 0, 0)

        return true
    end

    return false
end

end