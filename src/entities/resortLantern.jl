module ResortLantern

placements = Dict{String, Main.EntityPlacement}(
    "Resort Lantern" => Main.EntityPlacement(
        Main.Maple.ResortLantern
    )
)

function isLeftSide(entity::Main.Maple.Entity, room::Main.Maple.Room)
    x, y = Main.entityTranslation(entity)
    tx, ty = floor(Int, x / 8), floor(Int, y / 8)

    return get(room.fgTiles.data, (ty, tx + 2), '0') == '0'
end

function selection(entity::Main.Maple.Entity)
    x, y = Main.entityTranslation(entity)

    if entity.name == "resortLantern"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 9, y - 9, 18, 20)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "resortLantern"
        leftSide = isLeftSide(entity, room)

        Main.drawSprite(ctx, "objects/resortLantern/holder.png", 0, 0, sx=leftSide? 1 : -1)
        Main.drawSprite(ctx, "objects/resortLantern/lantern00.png", 0, 0, sx=leftSide? 1 : -1)

        return true
    end

    return false
end

end