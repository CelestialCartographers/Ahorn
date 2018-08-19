module Spinner

using ..Ahorn, Maple

function rotatingSpinnerFinalizer(entity::Maple.Entity)
    x, y = Int(entity.data["x"]), Int(entity.data["y"])
    entity.data["x"], entity.data["y"] = x + 32, y
    entity.data["nodes"] = [(x, y)]
end

placements = Dict{String, Ahorn.EntityPlacement}(
    "Dust Sprite" => Ahorn.EntityPlacement(
        Maple.Spinner,
        "point",
        Dict{String, Any}(
            "dust" => true
        )
    ),
    "Dust Sprite (Attached)" => Ahorn.EntityPlacement(
        Maple.Spinner,
        "point",
        Dict{String, Any}(
            "dust" => true,
            "attachToSolid" => true,
        )
    ),

    "Dust Sprite (Rotating, Clockwise)" => Ahorn.EntityPlacement(
        Maple.RotateSpinner,
        "point",
        Dict{String, Any}(
            "dust" => true,
            "clockwise" => true
        ),
        rotatingSpinnerFinalizer
    ),
    "Dust Sprite (Rotating)" => Ahorn.EntityPlacement(
        Maple.RotateSpinner,
        "point",
        Dict{String, Any}(
            "dust" => true,
            "clockwise" => false
        ),
        rotatingSpinnerFinalizer
    ),
    "Blade (Rotating, Clockwise)" => Ahorn.EntityPlacement(
        Maple.RotateSpinner,
        "point",
        Dict{String, Any}(
            "dust" => false,
            "clockwise" => true
        ),
        rotatingSpinnerFinalizer
    ),
    "Blade (Rotating)" => Ahorn.EntityPlacement(
        Maple.RotateSpinner,
        "point",
        Dict{String, Any}(
            "dust" => false,
            "clockwise" => false
        ),
        rotatingSpinnerFinalizer
    ),
)

crystalSpinnerColors = Maple.crystal_colors
for color in crystalSpinnerColors
    for attached in false:true
        key = "Crystal Spinner ($(titlecase(color))$(attached? ", Attached" : ""))"
        placements[key] = Ahorn.EntityPlacement(
            Maple.Spinner,
            "point",
            Dict{String, Any}(
                "color" => color,
                "attachToSolid" => attached,
            )
        )
    end
end

speeds = Maple.track_spinner_speeds
for speed in speeds, dusty in false:true
    key = (dusty? "Dust Sprite" : "Blade") * " (Track, $(titlecase(speed)))"
    placements[key] = Ahorn.EntityPlacement(
        Maple.TrackSpinner,
        "point",
        Dict{String, Any}(
            "dust" => dusty,
            "speed" => speed
        ),
        function(entity::Maple.Entity)
            x, y = Int(entity.data["x"]), Int(entity.data["y"])
            entity.data["nodes"] = [(x + 32, y)]
        end
    )
end

function editingOptions(entity::Maple.Entity)
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

function nodeLimits(entity::Maple.Entity)
    if entity.name == "rotateSpinner" || entity.name == "trackSpinner"
        return true, 1, 1
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "spinner"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 8, y - 8, 16, 16)

    elseif entity.name == "rotateSpinner"
        nx, ny = Int.(entity.data["nodes"][1])
        x, y = Ahorn.entityTranslation(entity)

        return true, [Ahorn.Rectangle(x - 8, y - 8, 16, 16), Ahorn.Rectangle(nx - 8, ny - 8, 16, 16)]

    elseif entity.name == "trackSpinner"
        startX, startY = Ahorn.entityTranslation(entity)
        stopX, stopY = Int.(entity.data["nodes"][1])

        return true, [Ahorn.Rectangle(startX - 8, startY - 8, 16, 16), Ahorn.Rectangle(stopX - 8, stopY - 8, 16, 16)]
    end
end

function renderMovingSpinner(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, x::Number, y::Number)
    dusty = get(entity.data, "dust", false)

    if dusty
        Ahorn.drawSprite(ctx, "danger/dustcreature/base00.png", x, y)
        Ahorn.drawSprite(ctx, "danger/dustcreature/center00.png", x, y)

    else
        Ahorn.drawSprite(ctx, "danger/blade00.png", x, y)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    # TODO - Add support for background, requires refactoring

    if entity.name == "spinner"
        # Custom attributes from Everest
        dusty = get(entity.data, "dust", false)
        color = lowercase(get(entity.data, "color", "blue"))

        if dusty
            Ahorn.drawSprite(ctx, "danger/dustcreature/base00.png", 0, 0)
            Ahorn.drawSprite(ctx, "danger/dustcreature/center00.png", 0, 0)

        else
            color = color == "core"? "blue" : color
            Ahorn.drawSprite(ctx, "danger/crystal/fg_$(color)03.png", 0, 0)
        end

        return true
    end

    return false
end

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "rotateSpinner"
        clockwise = get(entity.data, "clockwise", false)
        dir = clockwise? 1 : -1

        centerX, centerY = Int.(entity.data["nodes"][1])
        x, y = Ahorn.entityTranslation(entity)

        radius = sqrt((centerX - x)^2 + (centerY - y)^2)

        Ahorn.drawCircle(ctx, centerX, centerY, radius, Ahorn.colors.selection_selected_fc)
        Ahorn.drawArrow(ctx, centerX + radius, centerY, centerX + radius, centerY + 0.001 * dir, Ahorn.colors.selection_selected_fc, headLength=6)
        Ahorn.drawArrow(ctx, centerX - radius, centerY, centerX - radius, centerY + 0.001 * -dir, Ahorn.colors.selection_selected_fc, headLength=6)

        renderMovingSpinner(ctx, entity, x, y)

        return true

    elseif entity.name == "trackSpinner"
        startX, startY = Ahorn.entityTranslation(entity)
        stopX, stopY = entity.data["nodes"][1]

        renderMovingSpinner(ctx, entity, stopX, stopY)
        Ahorn.drawArrow(ctx, startX, startY, stopX, stopY, Ahorn.colors.selection_selected_fc, headLength=10)

        return true
    end
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "rotateSpinner"
        centerX, centerY = entity.data["nodes"][1]

        renderMovingSpinner(ctx, entity, centerX, centerY)

        return true

    elseif entity.name == "trackSpinner"
        startX, startY = Ahorn.entityTranslation(entity)

        renderMovingSpinner(ctx, entity, startX, startY)

        return true
    end
end

end