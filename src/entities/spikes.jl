module Spikes

placements = Dict{String, Main.EntityPlacement}()

variants = ["default", "cliffside", "tentacles", "reflection"]
entities = Dict{String, Function}(
    "up" => Main.Maple.SpikesUp,
    "down" => Main.Maple.SpikesDown,
    "left" => Main.Maple.SpikesLeft,
    "right" => Main.Maple.SpikesRight,
)

triggerEntities = Dict{String, Function}(
    "up" => Main.Maple.TriggerSpikesUp,
    "down" => Main.Maple.TriggerSpikesDown,
    "left" => Main.Maple.TriggerSpikesLeft,
    "right" => Main.Maple.TriggerSpikesRight,
)


for variant in variants
    for (dir, entity) in entities
        key = "Spikes ($(titlecase(dir)), $(titlecase(variant)))"
        placements[key] = Main.EntityPlacement(
            entity,
            "rectangle",
            Dict{String, Any}(
                "type" => variant
            )
        )
    end
end

for (dir, entity) in triggerEntities
    key = "Trigger Spikes ($(titlecase(dir)))"
    placements[key] = Main.EntityPlacement(
        entity,
        "rectangle"
    )
end

directions = Dict{String, String}(
    "spikesUp" => "up",
    "spikesDown" => "down",
    "spikesLeft" => "left",
    "spikesRight" => "right",

    "triggerSpikesUp" => "up",
    "triggerSpikesDown" => "down",
    "triggerSpikesLeft" => "left",
    "triggerSpikesRight" => "right",
)

offsets = Dict{String, Tuple{Integer, Integer}}(
    "up" => (4, -4),
    "down" => (4, 4),
    "left" => (-4, 4),
    "right" => (4, 4),
)

rotations = Dict{String, Number}(
    "up" => 0,
    "right" => pi / 2,
    "down" => pi,
    "left" => pi * 3 / 2
)

rotationOffsets = Dict{String, Tuple{Number, Number}}(
    "up" => (0.5, 0.25),
    "right" => (1, 0.675),
    "down" => (1.5, 1.125),
    "left" => (0, 1.675)
)

resizeDirections = Dict{String, Tuple{Bool, Bool}}(
    "up" => (true, false),
    "down" => (true, false),
    "left" => (false, true),
    "right" => (false, true),
)

tentacleSelectionOffsets = Dict{String, Tuple{Number, Number}}(
    "up" => (0, -8),
    "down" => (0, -8),
    "left" => (-8, 0),
    "right" => (-8, 0)
)

triggerNames = ["triggerSpikesDown", "triggerSpikesLeft", "triggerSpikesRight", "triggerSpikesUp"]
triggerRotationOffsets = Dict{String, Tuple{Number, Number}}(
    "up" => (3, -1),
    "right" => (4, 3),
    "down" => (5, 5),
    "left" => (-1, 4),
)

function selection(entity::Main.Maple.Entity)
    if haskey(directions, entity.name)
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        direction = get(directions, entity.name, "up")
        variant = get(entity.data, "type", "default")

        if variant == "tentacles"
            ox, oy = tentacleSelectionOffsets[direction]

            width = Int(get(entity.data, "width", 16))
            height = Int(get(entity.data, "height", 16))

            return true, Main.Rectangle(x + ox, y + oy, width, height)

        else
            width = Int(get(entity.data, "width", 8))
            height = Int(get(entity.data, "height", 8))

            ox, oy = offsets[direction]

            return true, Main.Rectangle(x + ox - 4, y + oy - 4, width, height)
        end
    end
end

function minimumSize(entity::Main.Maple.Entity)
    if haskey(directions, entity.name)
        variant = get(entity.data, "type", "default")
        direction = get(directions, entity.name, "up")

        if variant == "tentacles"
            return true, 16, 16

        else
            return true, 8, 8
        end
    end
end

function resizable(entity::Main.Maple.Entity)
    if haskey(directions, entity.name)
        variant = get(entity.data, "type", "default")
        direction = get(directions, entity.name, "up")

        if variant == "tentacles"
            return true, true, true

        else
            return true, resizeDirections[direction]...
        end
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity)
    # TODO - Tint trigger spikes

    if haskey(directions, entity.name)
        variant = entity.name in triggerNames? "trigger" : get(entity.data, "type", "default")
        direction = get(directions, entity.name, "up")

        if variant == "tentacles"
            width = get(entity.data, "width", 16)
            height = get(entity.data, "height", 16)

            for ox in 0:16:width - 16, oy in 0:16:height - 16
                drawX, drawY = (ox, oy) .+ (16, 16) .* rotationOffsets[direction]
                Main.drawSprite(ctx, "danger/tentacles00.png", drawX, drawY, rot=rotations[direction])
            end

            if width / 8 % 2 == 1 || height / 8 % 2 == 1
                drawX, drawY = (width - 16, height - 16) .+ (16, 16) .* rotationOffsets[direction]
                Main.drawSprite(ctx, "danger/tentacles00.png", drawX, drawY, rot=rotations[direction])
            end

        elseif variant == "trigger"
            width = get(entity.data, "width", 8)
            height = get(entity.data, "height", 8)

            updown = direction == "up" || direction == "down"

            for ox in 0:8:width - 8, oy in 0:8:height - 8
                drawX, drawY = (ox, oy) .+ triggerRotationOffsets[direction]
                Main.drawSprite(ctx, "danger/triggertentacle/wiggle_v06.png", drawX, drawY, rot=rotations[direction])
                Main.drawSprite(ctx, "danger/triggertentacle/wiggle_v03.png", drawX + 3 * updown, drawY + 3 * !updown, rot=rotations[direction])
            end

        else        
            width = get(entity.data, "width", 8)
            height = get(entity.data, "height", 8)

            for ox in 0:8:width - 8, oy in 0:8:height - 8
                drawX, drawY = (ox, oy) .+ offsets[direction]
                Main.drawSprite(ctx, "danger/spikes/$(variant)_$(direction)00.png", drawX, drawY)
            end
        end

        return true
    end

    return false
end

end