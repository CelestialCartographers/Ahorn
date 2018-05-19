module Platforms

placements = Dict{String, Main.EntityPlacement}(
    "Platform (Moving)" => Main.EntityPlacement(
        Main.Maple.MovingPlatform,
        "rectangle",
        Dict{String, Any}(),
        function(entity)
            x, y = Int(entity.data["x"]), Int(entity.data["y"])
            width = Int(get(entity.data, "width", 8))
            entity.data["x"], entity.data["y"] = x + width, y
            entity.data["nodes"] = [(x, y)]
        end
    ),
    "Platform (Sinking)" => Main.EntityPlacement(
        Main.Maple.SinkingPlatform,
        "rectangle"
    ),
)

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "movingPlatform"
        return true, 1, 1
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "movingPlatform" || entity.name == "sinkingPlatform"
        return true, true, false
    end
end

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "movingPlatform" || entity.name == "sinkingPlatform"
        return true, 8, 0
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "sinkingPlatform"
        x, y = Main.entityTranslation(entity)
        width = Int(get(entity.data, "width", 8))

        return true, Main.Rectangle(x, y, width, 8)

    elseif entity.name == "movingPlatform"
        width = Int(get(entity.data, "width", 8))
        startX, startY = Int(entity.data["x"]), Int(entity.data["y"])
        stopX, stopY = Int.(entity.data["nodes"][1])

        return true, [Main.Rectangle(startX, startY, width, 8), Main.Rectangle(stopX, stopY, width, 8)]
    end
end

outerColor = (30, 14, 25) ./ 255
innerColor = (10, 0, 6) ./ 255

function renderConnection(ctx::Main.Cairo.CairoContext, x::Number, y::Number, nx::Number, ny::Number, width::Number)
    cx, cy = x + floor(Int, width / 2), y + 4
    cnx, cny = nx + floor(Int, width / 2), ny + 4

    length = sqrt((x - nx)^2 + (y - ny)^2)
    theta = atan2(cny - cy, cnx - cx)

    Main.Cairo.save(ctx)

    Main.translate(ctx, cx, cy)
    Main.rotate(ctx, theta)

    Main.setSourceColor(ctx, outerColor)
    Main.set_antialias(ctx, 1)
    Main.set_line_width(ctx, 3);

    Main.move_to(ctx, 0, 0)
    Main.line_to(ctx, length, 0)

    Main.stroke(ctx)

    Main.setSourceColor(ctx, innerColor)
    Main.set_antialias(ctx, 1)
    Main.set_line_width(ctx, 1);

    Main.move_to(ctx, 0, 0)
    Main.line_to(ctx, length, 0)

    Main.stroke(ctx)

    Main.Cairo.restore(ctx)
end

function renderPlatform(ctx::Main.Cairo.CairoContext, x::Number, y::Number, width::Number)
    tilesWidth = div(width, 8)

    for i in 2:tilesWidth - 1
        Main.drawImage(ctx, "objects/woodPlatform/default", x + 8 * (i - 1), y, 8, 0, 8, 8)
    end

    Main.drawImage(ctx, "objects/woodPlatform/default", x, y, 0, 0, 8, 8)
    Main.drawImage(ctx, "objects/woodPlatform/default", x + tilesWidth * 8 - 8, y, 24, 0, 8, 8)
    Main.drawImage(ctx, "objects/woodPlatform/default", x + floor(Int, width / 2) - 4, y, 16, 0, 8, 8)
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "movingPlatform"
        width = Int(get(entity.data, "width", 8))
        x, y = Int(entity.data["x"]), Int(entity.data["y"])
        nx, ny = Int.(entity.data["nodes"][1])

        renderConnection(ctx, x, y, nx, ny, width)
        renderPlatform(ctx, x, y, width)

        return true

    elseif entity.name == "sinkingPlatform"
        width = Int(get(entity.data, "width", 8))
        x, y = Int(entity.data["x"]), Int(entity.data["y"])

        renderConnection(ctx, x, y, x, Int(Main.loadedRoom.size[2]), width)
        renderPlatform(ctx, x, y, width)

        return true
    end

    return false
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "movingPlatform"
        width = Int(get(entity.data, "width", 8))
        startX, startY = Int(entity.data["x"]), Int(entity.data["y"])
        stopX, stopY = Int.(entity.data["nodes"][1])

        renderPlatform(ctx, startX, startY, width)
        renderPlatform(ctx, stopX, stopY, width)

        Main.drawArrow(ctx, startX + width / 2, startY, stopX + width / 2, stopY, Main.colors.selection_selected_fc, headLength=6)

        return true
    end
end

end