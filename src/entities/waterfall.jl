module Waterfall

function getHeight(entity::Main.Maple.Entity, room::Main.Maple.Room)
    waterEntities = filter(e -> e.name == "water", room.entities)
    waterRects = [
        Main.Rectangle(
            Int(get(e.data, "x", 0)),
            Int(get(e.data, "y", 0)),
            Int(get(e.data, "width", 8)),
            Int(get(e.data, "height", 8))
        ) for e in waterEntities
    ]

    width, height = room.size
    x, y = Int(get(entity.data, "x", 0)), Int(get(entity.data, "y", 0))
    tx, ty = floor(Int, x / 8) + 1, floor(Int, y / 8) + 1

    wantedHeight = 8 - y % 8
    while wantedHeight < height - y
        rect = Main.Rectangle(x, y, 8, wantedHeight + 8)

        if any(Main.checkCollision.(waterRects, rect))
            break
        end

        if get(room.fgTiles.data, (ty + 1, tx), '0') != '0'
            break
        end

        wantedHeight += 8
        ty += 1
    end

    return wantedHeight
end

placements = Dict{String, Main.EntityPlacement}(
    "Waterfall" => Main.EntityPlacement(
        Main.Maple.Waterfall
    )
)

waterfallColor = (135, 206, 250, 1) ./ (255, 255, 255, 1.0) .* (0.6, 0.6, 0.6, 0.95)

function selection(entity::Main.Maple.Entity)
    if entity.name == "waterfall"
        x, y = Main.entityTranslation(entity)

        # TODO - Handle room in selections better, this is bound to cause problems down the road
        height = getHeight(entity, Main.loadedState.room)

        return true, Main.Rectangle(x, y, 8, height)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "waterfall"
        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))

        height = getHeight(entity, room)

        Main.drawRectangle(ctx, 0, 0, 8, height, waterfallColor, (0.0, 0.0, 0.0, 0.0))

        return true
    end

    return false
end

end