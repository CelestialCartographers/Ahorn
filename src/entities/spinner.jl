module Spinner

function rotatingSpinnerFinalizer(entity::Main.Maple.Entity)
    x, y = Int(entity.data["x"]), Int(entity.data["y"])
    entity.data["x"], entity.data["y"] = x + 32, y
    entity.data["nodes"] = [(x, y)]
end

placements = Dict{String, Main.EntityPlacement}(
    "Dust Sprite" => Main.EntityPlacement(
        Main.Maple.Spinner,
        "point",
        Dict{String, Any}(
            "dust" => true
        )
    ),
    "Dust Sprite (Attached)" => Main.EntityPlacement(
        Main.Maple.Spinner,
        "point",
        Dict{String, Any}(
            "dust" => true,
            "attachToSolid" => true,
        )
    ),

    "Dust Sprite (Rotating, Clockwise)" => Main.EntityPlacement(
        Main.Maple.RotateSpinner,
        "point",
        Dict{String, Any}(
            "dust" => true,
            "clockwise" => true
        ),
        rotatingSpinnerFinalizer
    ),
    "Dust Sprite (Rotating)" => Main.EntityPlacement(
        Main.Maple.RotateSpinner,
        "point",
        Dict{String, Any}(
            "dust" => true,
            "clockwise" => false
        ),
        rotatingSpinnerFinalizer
    ),
    "Blade (Rotating, Clockwise)" => Main.EntityPlacement(
        Main.Maple.RotateSpinner,
        "point",
        Dict{String, Any}(
            "dust" => false,
            "clockwise" => true
        ),
        rotatingSpinnerFinalizer
    ),
    "Blade (Rotating)" => Main.EntityPlacement(
        Main.Maple.RotateSpinner,
        "point",
        Dict{String, Any}(
            "dust" => false,
            "clockwise" => false
        ),
        rotatingSpinnerFinalizer
    ),
)

crystalSpinnerColors = Main.Maple.crystal_colors
for color in crystalSpinnerColors
    for attached in false:true
        key = "Crystal Spinner ($(titlecase(color))$(attached? ", Attached" : ""))"
        placements[key] = Main.EntityPlacement(
            Main.Maple.Spinner,
            "point",
            Dict{String, Any}(
                "color" => color,
                "attachToSolid" => attached,
            )
        )
    end
end

speeds = Main.Maple.track_spinner_speeds
for speed in speeds, dusty in false:true
    key = (dusty? "Dust Sprite" : "Blade") * " (Track, $(titlecase(speed)))"
    placements[key] = Main.EntityPlacement(
        Main.Maple.TrackSpinner,
        "point",
        Dict{String, Any}(
            "dust" => dusty,
            "speed" => speed
        ),
        function(entity::Main.Maple.Entity)
            x, y = Int(entity.data["x"]), Int(entity.data["y"])
            entity.data["nodes"] = [(x + 32, y)]
        end
    )
end

function editingOptions(entity::Main.Maple.Entity)
    if entity.name == "trackSpinner"
        return true, Dict{String, Any}(
            "speed" => speeds
        )

    elseif entity.name == "spinner"
        return true, Dict{String, Any}(
            "color" => crystalSpinnerColors
        )
    end
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
        nx, ny = Int.(entity.data["nodes"][1])
        x, y = Main.entityTranslation(entity)

        return true, [Main.Rectangle(x - 8, y - 8, 16, 16), Main.Rectangle(nx - 8, ny - 8, 16, 16)]

    elseif entity.name == "trackSpinner"
        startX, startY = Main.entityTranslation(entity)
        stopX, stopY = Int.(entity.data["nodes"][1])

        return true, [Main.Rectangle(startX - 8, startY - 8, 16, 16), Main.Rectangle(stopX - 8, stopY - 8, 16, 16)]
    end
end

function renderMovingSpinner(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, x::Number, y::Number)
    dusty = get(entity.data, "dust", false)

    if dusty
        Main.drawSprite(ctx, "danger/dustcreature/base00.png", x, y)
        Main.drawSprite(ctx, "danger/dustcreature/center00.png", x, y)

    else
        Main.drawSprite(ctx, "danger/blade00.png", x, y)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    # TODO - Add support for background, requires refactoring

    if entity.name == "spinner"
        # Custom attributes from Everest
        dusty = get(entity.data, "dust", false)
        color = lowercase(get(entity.data, "color", "blue"))

        if dusty
            Main.drawSprite(ctx, "danger/dustcreature/base00.png", 0, 0)
            Main.drawSprite(ctx, "danger/dustcreature/center00.png", 0, 0)

        else
            color = color == "core"? "blue" : color
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
        x, y = Main.entityTranslation(entity)

        radius = sqrt((centerX - x)^2 + (centerY - y)^2)

        Main.drawCircle(ctx, centerX, centerY, radius, Main.colors.selection_selected_fc)
        Main.drawArrow(ctx, centerX + radius, centerY, centerX + radius, centerY + 0.001 * dir, Main.colors.selection_selected_fc, headLength=6)
        Main.drawArrow(ctx, centerX - radius, centerY, centerX - radius, centerY + 0.001 * -dir, Main.colors.selection_selected_fc, headLength=6)

        renderMovingSpinner(ctx, entity, x, y)

        return true

    elseif entity.name == "trackSpinner"
        startX, startY = Main.entityTranslation(entity)
        stopX, stopY = entity.data["nodes"][1]

        renderMovingSpinner(ctx, entity, stopX, stopY)
        Main.drawArrow(ctx, startX, startY, stopX, stopY, Main.colors.selection_selected_fc, headLength=10)

        return true
    end
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "rotateSpinner"
        centerX, centerY = entity.data["nodes"][1]

        renderMovingSpinner(ctx, entity, centerX, centerY)

        return true

    elseif entity.name == "trackSpinner"
        startX, startY = Main.entityTranslation(entity)

        renderMovingSpinner(ctx, entity, startX, startY)

        return true
    end
end

end