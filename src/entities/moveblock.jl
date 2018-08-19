module MoveBlock

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}()

directions = Maple.move_block_directions
for direction in directions, steerable in false:true, fast in false:true
    key = "Move Block ($(titlecase(direction)), $(fast? "Fast" : "Slow")$(steerable? ", Steerable" :    ""))"
    placements[key] = Ahorn.EntityPlacement(
        Maple.MoveBlock,
        "rectangle",
        Dict{String, Any}(
            "canSteer" => steerable,
            "direction" => direction,
            "fast" => fast
        )
    )
end

function editingOptions(entity::Maple.Entity)
    if entity.name == "moveBlock"
        return true, Dict{String, Any}(
            "direction" => Maple.move_block_directions
        )
    end
end

function minimumSize(entity::Maple.Entity)
    if entity.name == "moveBlock"
        return true, 16, 16
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "moveBlock"
        return true, true, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "moveBlock"
        x, y = Ahorn.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, Ahorn.Rectangle(x, y, width, height)
    end
end

midColor = (4, 3, 23) ./ 255
highlightColor = (59, 50, 101) ./ 255

arrows = Dict{String, String}(
    "up" => "objects/moveBlock/arrow02",
    "left" => "objects/moveBlock/arrow04",
    "right" => "objects/moveBlock/arrow00",
    "down" => "objects/moveBlock/arrow06",
)

button = "objects/moveBlock/button"

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "moveBlock"
        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))


        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        tilesWidth = div(width, 8)
        tilesHeight = div(height, 8)

        canSteer = get(entity.data, "canSteer", false)
        direction = lowercase(get(entity.data, "direction", "up"))
        arrowSprite = Ahorn.sprites[arrows[lowercase(direction)]]

        frame = "objects/moveBlock/base"
        if canSteer
            if direction == "up" || direction == "down"
                frame = "objects/moveBlock/base_v"

            else
                frame = "objects/moveBlock/base_h"
            end
        end

        Ahorn.drawRectangle(ctx, 2, 2, width - 4, height - 4, highlightColor, highlightColor)
        Ahorn.drawRectangle(ctx, 8, 8, width - 16, height - 16, midColor)

        for i in 2:tilesWidth - 1
            Ahorn.drawImage(ctx, frame, (i - 1) * 8, 0, 8, 0, 8, 8)
            Ahorn.drawImage(ctx, frame, (i - 1) * 8, height - 8, 8, 16, 8, 8)

            if canSteer && (direction != "up" && direction != "down")
                Ahorn.drawImage(ctx, button, (i - 1) * 8, -2, 6, 0, 8, 6)
            end
        end

        for i in 2:tilesHeight - 1
            Ahorn.drawImage(ctx, frame, 0, (i - 1) * 8, 0, 8, 8, 8)
            Ahorn.drawImage(ctx, frame, width - 8, (i - 1) * 8, 16, 8, 8, 8)

            if canSteer && (direction == "up" || direction == "down")
                Ahorn.Cairo.save(ctx)

                Ahorn.rotate(ctx, -pi / 2)
                Ahorn.drawImage(ctx, button, i * 8 - height - 8, -2, 6, 0, 8, 6)
                Ahorn.scale(ctx, 1, -1)
                Ahorn.drawImage(ctx, button, i * 8 - height - 8, -2 - width, 6, 0, 8, 6)

                Ahorn.Cairo.restore(ctx)
            end
        end

        Ahorn.drawImage(ctx, frame, 0, 0, 0, 0, 8, 8)
        Ahorn.drawImage(ctx, frame, width - 8, 0, 16, 0, 8, 8)
        Ahorn.drawImage(ctx, frame, 0, height - 8, 0, 16, 8, 8)
        Ahorn.drawImage(ctx, frame, width - 8, height - 8, 16, 16, 8, 8)

        if canSteer && (direction != "up" && direction != "down")
            Ahorn.Cairo.save(ctx)

            Ahorn.drawImage(ctx, button, 2, -2, 0, 0, 6, 6)
            Ahorn.scale(ctx, -1, 1)
            Ahorn.drawImage(ctx, button, 2 - width, -2, 0, 0, 6, 6)

            Ahorn.Cairo.restore(ctx)
        end

        if canSteer && (direction == "up" || direction == "down")
            Ahorn.Cairo.save(ctx)

            Ahorn.rotate(ctx, -pi / 2)
            Ahorn.drawImage(ctx, button, -height + 2, -2, 0, 0, 6, 6)
            Ahorn.drawImage(ctx, button, -8, -2, 14, 0, 6, 6)
            Ahorn.scale(ctx, 1, -1)
            Ahorn.drawImage(ctx, button, -height + 2, -2 -width, 0, 0, 6, 6)
            Ahorn.drawImage(ctx, button, -8, -2 -width, 14, 0, 6, 6)

            Ahorn.Cairo.restore(ctx)
        end

        Ahorn.drawRectangle(ctx, div(width - arrowSprite.width, 2) + 1, div(height - arrowSprite.height, 2) + 1, 8, 8, highlightColor, highlightColor)
        Ahorn.drawImage(ctx, arrowSprite, div(width - arrowSprite.width, 2), div(height - arrowSprite.height, 2))

        return true
    end

    return false
end

end