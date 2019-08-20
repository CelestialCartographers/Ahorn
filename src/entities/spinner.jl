module Spinner

using ..Ahorn, Maple

function rotatingSpinnerFinalizer(entity::Maple.RotateSpinner)
    x, y = Int(entity.data["x"]), Int(entity.data["y"])
    entity.data["x"], entity.data["y"] = x + 32, y
    entity.data["nodes"] = [(x, y)]
end

const movingSpinner = Union{Maple.TrackSpinner, Maple.RotateSpinner}

const placements = Ahorn.PlacementDict(
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
        key = "Crystal Spinner ($(uppercasefirst(color))$(attached ? ", Attached" : ""))"
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
    key = (dusty ? "Dust Sprite" : "Blade") * " (Track, $(uppercasefirst(speed)))"
    placements[key] = Ahorn.EntityPlacement(
        Maple.TrackSpinner,
        "line",
        Dict{String, Any}(
            "dust" => dusty,
            "speed" => speed
        )
    )
end

Ahorn.editingOptions(entity::Maple.Spinner) = Dict{String, Any}(
    "color" => crystalSpinnerColors
)

Ahorn.editingOptions(entity::Maple.TrackSpinner) = Dict{String, Any}(
    "color" => crystalSpinnerColors
)

Ahorn.nodeLimits(entity::Maple.TrackSpinner) = 1, 1
Ahorn.nodeLimits(entity::Maple.RotateSpinner) = 1, 1

function Ahorn.selection(entity::Maple.Spinner)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - 8, y - 8, 16, 16)
end

function Ahorn.selection(entity::Maple.RotateSpinner)
    nx, ny = Int.(entity.data["nodes"][1])
    x, y = Ahorn.position(entity)

    return [Ahorn.Rectangle(x - 8, y - 8, 16, 16), Ahorn.Rectangle(nx - 8, ny - 8, 16, 16)]
end

function Ahorn.selection(entity::Maple.TrackSpinner)
    startX, startY = Ahorn.position(entity)
    stopX, stopY = Int.(entity.data["nodes"][1])

    return [Ahorn.Rectangle(startX - 8, startY - 8, 16, 16), Ahorn.Rectangle(stopX - 8, stopY - 8, 16, 16)]
end

function renderMovingSpinner(ctx::Ahorn.Cairo.CairoContext, entity::movingSpinner, x::Number, y::Number)
    dusty = get(entity.data, "dust", false)

    if dusty
        Ahorn.drawSprite(ctx, "danger/dustcreature/base00", x, y)
        Ahorn.drawSprite(ctx, "danger/dustcreature/center00", x, y)

    else
        Ahorn.drawSprite(ctx, "danger/blade00", x, y)
    end
end

# TODO - Add support for background
function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Spinner, room::Maple.Room)
    # Custom attributes from Everest
    dusty = get(entity.data, "dust", false)
    color = lowercase(get(entity.data, "color", "blue"))

    if dusty
        Ahorn.drawSprite(ctx, "danger/dustcreature/base00", 0, 0)
        Ahorn.drawSprite(ctx, "danger/dustcreature/center00", 0, 0)

    else
        color = color == "core" ? "blue" : color
        Ahorn.drawSprite(ctx, "danger/crystal/fg_$(color)03", 0, 0)
    end
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.RotateSpinner, room::Maple.Room)
    clockwise = get(entity.data, "clockwise", false)
    dir = clockwise ? 1 : -1

    centerX, centerY = Int.(entity.data["nodes"][1])
    x, y = Ahorn.position(entity)

    radius = sqrt((centerX - x)^2 + (centerY - y)^2)

    Ahorn.drawCircle(ctx, centerX, centerY, radius, Ahorn.colors.selection_selected_fc)
    Ahorn.drawArrow(ctx, centerX + radius, centerY, centerX + radius, centerY + 0.001 * dir, Ahorn.colors.selection_selected_fc, headLength=6)
    Ahorn.drawArrow(ctx, centerX - radius, centerY, centerX - radius, centerY + 0.001 * -dir, Ahorn.colors.selection_selected_fc, headLength=6)

    renderMovingSpinner(ctx, entity, x, y)
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.TrackSpinner, room::Maple.Room)
    startX, startY = Ahorn.position(entity)
    stopX, stopY = entity.data["nodes"][1]

    renderMovingSpinner(ctx, entity, stopX, stopY)
    Ahorn.drawArrow(ctx, startX, startY, stopX, stopY, Ahorn.colors.selection_selected_fc, headLength=10)
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.RotateSpinner, room::Maple.Room)
    centerX, centerY = Int.(entity.data["nodes"][1])

    renderMovingSpinner(ctx, entity, centerX, centerY)
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.TrackSpinner, room::Maple.Room)
    startX, startY = Ahorn.position(entity)

    renderMovingSpinner(ctx, entity, startX, startY)
end

end