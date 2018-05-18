module Spinner

placements = Dict{String, Main.EntityPlacement}(
    "Crystal Spinner (Blue)" => Main.EntityPlacement(
        Main.Maple.Spinner,
        "point",
        Dict{String, Any}(
            "color" => "blue"
        )
    ),
    "Crystal Spinner (Red)" => Main.EntityPlacement(
        Main.Maple.Spinner,
        "point",
        Dict{String, Any}(
            "color" => "red"
        )
    ),
    "Crystal Spinner (Purple)" => Main.EntityPlacement(
        Main.Maple.Spinner,
        "point",
        Dict{String, Any}(
            "color" => "purple"
        )
    ),
    "Dust Sprite" => Main.EntityPlacement(
        Main.Maple.Spinner,
        "point",
        Dict{String, Any}(
            "dust" => true
        )
    ),

    "Dust Sprite (Rotating, Clockwise)" => Main.EntityPlacement(
        Main.Maple.RotateSpinner,
        "point",
        Dict{String, Any}(
            "dust" => true,
            "clockwise" => true
        ),
        function(entity)
            x, y = Int(entity.data["x"]), Int(entity.data["y"])
            entity.data["x"], entity.data["y"] = x + 32, y
            entity.data["nodes"] = [(x, y)]
        end
    ),
    "Dust Sprite (Rotating)" => Main.EntityPlacement(
        Main.Maple.RotateSpinner,
        "point",
        Dict{String, Any}(
            "dust" => true,
            "clockwise" => false
        ),
        function(entity)
            x, y = Int(entity.data["x"]), Int(entity.data["y"])
            entity.data["x"], entity.data["y"] = x + 32, y
            entity.data["nodes"] = [(x, y)]
        end
    ),
    "Blade (Rotating, Clockwise)" => Main.EntityPlacement(
        Main.Maple.RotateSpinner,
        "point",
        Dict{String, Any}(
            "dust" => false,
            "clockwise" => true
        ),
        function(entity)
            x, y = Int(entity.data["x"]), Int(entity.data["y"])
            entity.data["x"], entity.data["y"] = x + 32, y
            entity.data["nodes"] = [(x, y)]
        end
    ),
    "Blade (Rotating)" => Main.EntityPlacement(
        Main.Maple.RotateSpinner,
        "point",
        Dict{String, Any}(
            "dust" => false,
            "clockwise" => false
        ),
        function(entity)
            x, y = Int(entity.data["x"]), Int(entity.data["y"])
            entity.data["x"], entity.data["y"] = x + 32, y
            entity.data["nodes"] = [(x, y)]
        end
    ),
)

speeds = ["slow", "normal", "fast"]

for speed in speeds, dusty in false:true
    key = (dusty? "Dust Sprite" : "Blade") * " (Track, $(titlecase(speed)))"
    placements[key] = Main.EntityPlacement(
        Main.Maple.TrackSpinner,
        "point",
        Dict{String, Any}(
            "dust" => dusty,
            "speed" => speed
        ),
        function(entity)
            x, y = Int(entity.data["x"]), Int(entity.data["y"])
            entity.data["nodes"] = [(x + 32, y)]
        end
    )
end

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "rotateSpinner" || entity.name == "trackSpinner"
        return true, 1, 1
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "spinner"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 8, y - 8, 16, 16)

    elseif entity.name == "rotateSpinner"
        x, y = Int.(entity.data["nodes"][1])

        return true, [Main.Rectangle(x - 8, y - 8, 16, 16), Main.Rectangle(x - 8, y - 8, 16, 8)]

    elseif entity.name == "trackSpinner"
        startX, startY = Int(entity.data["x"]), Int(entity.data["y"])
        stopX, stopY = entity.data["nodes"][1]

        return true, [Main.Rectangle(startX - 8, startY - 8, 16, 16), Main.Rectangle(stopX - 8, stopY - 8, 16, 16)]
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    # TODO - Add support for background, requires refactoring

    if entity.name == "spinner"
        # Custom attributes from Everest
        dusty = get(entity.data, "dust", false)
        color = get(entity.data, "color", "blue")

        if dusty  
            Main.drawSprite(ctx, "danger/dustcreature/base00.png", 0, 0)
            Main.drawSprite(ctx, "danger/dustcreature/center00.png", 0, 0)

        else
            Main.drawSprite(ctx, "danger/crystal/fg_$(color)03.png", 0, 0)
        end

        return true
    end

    return false
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "rotateSpinner"
        clockwise = get(entity.data, "clockwise", false)
        dir = clockwise? 1 : -1

        centerX, centerY = Int.(entity.data["nodes"][1])
        x, y = Int(entity.data["x"]), Int(entity.data["y"])

        radius = sqrt((centerX - x)^2 + (centerY - y)^2)

        Main.drawCircle(ctx, centerX, centerY, radius, Main.colors.selection_selected_fc)
        Main.drawArrow(ctx, centerX + radius, centerY, centerX + radius, centerY + 0.001 * dir, Main.colors.selection_selected_fc, headLength=6)
        Main.drawArrow(ctx, centerX - radius, centerY, centerX - radius, centerY + 0.001 * -dir, Main.colors.selection_selected_fc, headLength=6)

        return true

    elseif entity.name == "trackSpinner"
        dusty = get(entity.data, "dust", false)
        startX, startY = Int(entity.data["x"]), Int(entity.data["y"])
        stopX, stopY = entity.data["nodes"][1]

        if dusty
            Main.drawSprite(ctx, "danger/dustcreature/base00.png", stopX, stopY)
            Main.drawSprite(ctx, "danger/dustcreature/center00.png", stopX, stopY)

        else
            Main.drawSprite(ctx, "danger/blade00.png", stopX, stopY)
        end

        Main.drawArrow(ctx, startX, startY, stopX, stopY, Main.colors.selection_selected_fc, headLength=10)

        return true
    end
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "rotateSpinner"
        dusty = get(entity.data, "dust", false)
        centerX, centerY = entity.data["nodes"][1]

        if dusty
            Main.drawSprite(ctx, "danger/dustcreature/base00.png", centerX, centerY)
            Main.drawSprite(ctx, "danger/dustcreature/center00.png", centerX, centerY)

        else
            Main.drawSprite(ctx, "danger/blade00.png", centerX, centerY)
        end

        return true

    elseif entity.name == "trackSpinner"
        dusty = get(entity.data, "dust", false)
        startX, startY = Int(entity.data["x"]), Int(entity.data["y"])

        if dusty
            Main.drawSprite(ctx, "danger/dustcreature/base00.png", startX, startY)
            Main.drawSprite(ctx, "danger/dustcreature/center00.png", startX, startY)

        else
            Main.drawSprite(ctx, "danger/blade00.png", startX, startY)
        end

        return true
    end
end

end