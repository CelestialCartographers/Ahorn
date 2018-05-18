module zipMover

placements = Dict{String, Main.EntityPlacement}(
    "Zip Mover" => Main.EntityPlacement(
        Main.Maple.ZipMover,
        "rectangle",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + Int(entity.data["width"]) + 8, Int(entity.data["y"]))]
        end
    ),
)

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "dreamBlock"
        return true, 1, 1
    end
end

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "zipMover"
        return true, 16, 16
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "zipMover"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "zipMover"
        x, y = Main.entityTranslation(entity)
        nx, ny = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, [Main.Rectangle(x, y, width, height), Main.Rectangle(nx + floor(Int, width / 2) - 5, ny + floor(Int, height / 2) - 5, 10, 10)]
    end
end

ropeColor = (102, 57, 49) ./ 255
frame = "objects/zipmover/block"
lightSprite = Main.sprites["objects/zipmover/light01"]

function renderZipMover(ctx::Main.Cairo.CairoContext, x::Number, y::Number, width::Number, height::Number, nx::Number, ny::Number)
    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    cx, cy = x + floor(Int, width / 2), y + floor(Int, height / 2)
    cnx, cny = nx + floor(Int, width / 2), ny + floor(Int, height / 2)

    length = sqrt((x - nx)^2 + (y - ny)^2)
    theta = atan2(cny - cy, cnx - cx)

    Main.Cairo.save(ctx)

    Main.translate(ctx, cx, cy)
    Main.rotate(ctx, theta)

    Main.setSourceColor(ctx, ropeColor)
    Main.set_antialias(ctx, 1)
    Main.set_line_width(ctx, 1);

    Main.move_to(ctx, 0, 5)
    Main.line_to(ctx, length, 5)

    Main.move_to(ctx, 0, -4)
    Main.line_to(ctx, length, -4)

    Main.stroke(ctx)

    Main.Cairo.restore(ctx)

    Main.drawRectangle(ctx, x + 2, y + 2, width - 4, height - 4, (0.0, 0.0, 0.0, 1.0))
    Main.drawSprite(ctx, "objects/zipmover/cog.png", cnx, cny)

    for i in 2:tilesWidth - 1
        Main.drawImage(ctx, frame, x + (i - 1) * 8, y, 8, 0, 8, 8)
        Main.drawImage(ctx, frame, x + (i - 1) * 8, y + height - 8, 8, 16, 8, 8)
    end

    for i in 2:tilesHeight - 1
        Main.drawImage(ctx, frame, x, y + (i - 1) * 8, 0, 8, 8, 8)
        Main.drawImage(ctx, frame, x + width - 8, y + (i - 1) * 8, 16, 8, 8, 8)
    end

    Main.drawImage(ctx, frame, x, y, 0, 0, 8, 8)
    Main.drawImage(ctx, frame, x + width - 8, y, 16, 0, 8, 8)
    Main.drawImage(ctx, frame, x, y + height - 8, 0, 16, 8, 8)
    Main.drawImage(ctx, frame, x + width - 8, y + height - 8, 16, 16, 8, 8)

    Main.drawImage(ctx, lightSprite, x + floor(Int, (width - lightSprite.width) / 2), y)
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "zipMover"
        x, y = Main.entityTranslation(entity)
        nx, ny = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        renderZipMover(ctx, x, y, width, height, nx, ny)

        return true
    end

    return false
end

end