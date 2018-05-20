module moveBlock

placements = Dict{String, Main.EntityPlacement}()

directions = ["up", "right", "left"]

for direction in directions, steerable in false:true, fast in false:true
    key = "Move Block ($(titlecase(direction)), $(fast? "Fast" : "Slow")$(steerable? ", Steerable" :    ""))"
    placements[key] = Main.EntityPlacement(
        Main.Maple.MoveBlock,
        "rectangle",
        Dict{String, Any}(
            "canSteer" => steerable,
            "direction" => direction,
            "fast" => fast
        )
    )
end

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "moveBlock"
        return true, 24, 24
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "moveBlock"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "moveBlock"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Main.Rectangle(x, y, width, height)
    end
end

midColor = (4, 3, 23) ./ 255
highlightColor = (59, 50, 101) ./ 255

arrows = Dict{String, String}(
    "up" => "objects/moveBlock/arrow02",
    "left" => "objects/moveBlock/arrow04",
    "right" => "objects/moveBlock/arrow00"
)

button = "objects/moveBlock/button"

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "moveBlock"
        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))


        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        tilesWidth = div(width, 8)
        tilesHeight = div(height, 8)

        canSteer = get(entity.data, "canSteer", false)
        direction = get(entity.data, "direction", "up")
        arrowSprite = Main.sprites[arrows[lowercase(direction)]]

        frame = "objects/moveBlock/base"
        if canSteer
            if direction == "up"
                frame = "objects/moveBlock/base_v"

            else
                frame = "objects/moveBlock/base_h"
            end
        end

        Main.drawRectangle(ctx, 2, 2, width - 4, height - 4, highlightColor, highlightColor)
        Main.drawRectangle(ctx, 8, 8, width - 16, height - 16, midColor)

        for i in 2:tilesWidth - 1
            Main.drawImage(ctx, frame, (i - 1) * 8, 0, 8, 0, 8, 8)
            Main.drawImage(ctx, frame, (i - 1) * 8, height - 8, 8, 16, 8, 8)

            if canSteer && direction != "up"
                Main.drawImage(ctx, button, (i - 1) * 8, -2, 6, 0, 8, 6)
            end
        end

        for i in 2:tilesHeight - 1
            Main.drawImage(ctx, frame, 0, (i - 1) * 8, 0, 8, 8, 8)
            Main.drawImage(ctx, frame, width - 8, (i - 1) * 8, 16, 8, 8, 8)

            if canSteer && direction == "up"
                Main.Cairo.save(ctx)

                Main.rotate(ctx, -pi / 2)
                Main.drawImage(ctx, button, i * 8 - height - 8, -2, 6, 0, 8, 6)
                Main.scale(ctx, 1, -1)
                Main.drawImage(ctx, button, i * 8 - height - 8, -2 - width, 6, 0, 8, 6)

                Main.Cairo.restore(ctx)
            end
        end

        Main.drawImage(ctx, frame, 0, 0, 0, 0, 8, 8)
        Main.drawImage(ctx, frame, width - 8, 0, 16, 0, 8, 8)
        Main.drawImage(ctx, frame, 0, height - 8, 0, 16, 8, 8)
        Main.drawImage(ctx, frame, width - 8, height - 8, 16, 16, 8, 8)

        if canSteer && direction != "up"
            Main.Cairo.save(ctx)

            Main.drawImage(ctx, button, 2, -2, 0, 0, 6, 6)
            Main.scale(ctx, -1, 1)
            Main.drawImage(ctx, button, 2 - width, -2, 0, 0, 6, 6)

            Main.Cairo.restore(ctx)
        end

        if canSteer && direction == "up"
            Main.Cairo.save(ctx)

            Main.rotate(ctx, -pi / 2)
            Main.drawImage(ctx, button, -height + 2, -2, 0, 0, 6, 6)
            Main.drawImage(ctx, button, -8, -2, 14, 0, 6, 6)
            Main.scale(ctx, 1, -1)
            Main.drawImage(ctx, button, -height + 2, -2 -width, 0, 0, 6, 6)
            Main.drawImage(ctx, button, -8, -2 -width, 14, 0, 6, 6)

            Main.Cairo.restore(ctx)
        end


        Main.drawRectangle(ctx, div(width - arrowSprite.width, 2) + 1, div(height - arrowSprite.height, 2) + 1, 8, 8, highlightColor, highlightColor)
        Main.drawImage(ctx, arrowSprite, div(width - arrowSprite.width, 2), div(height - arrowSprite.height, 2))

        return true
    end

    return false
end

end