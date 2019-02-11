module Spikes

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict()

entities = Dict{String, Type}(
    "up" => Maple.SpikesUp,
    "down" => Maple.SpikesDown,
    "left" => Maple.SpikesLeft,
    "right" => Maple.SpikesRight,
)

triggerEntities = Dict{String, Type}(
    "up" => Maple.TriggerSpikesUp,
    "down" => Maple.TriggerSpikesDown,
    "left" => Maple.TriggerSpikesLeft,
    "right" => Maple.TriggerSpikesRight,
)

triggerEntitiesOrig = Dict{String, Type}(
    "up" => Maple.TriggerSpikesOriginalUp,
    "down" => Maple.TriggerSpikesOriginalDown,
    "left" => Maple.TriggerSpikesOriginalLeft,
    "right" => Maple.TriggerSpikesOriginalRight,
)

normalSpikesUnion = Union{Maple.SpikesUp, Maple.SpikesDown, Maple.SpikesLeft, Maple.SpikesRight}
triggerSpikesUnion = Union{Maple.TriggerSpikesUp, Maple.TriggerSpikesDown, Maple.TriggerSpikesLeft, Maple.TriggerSpikesRight}
triggerSpikesOrigUnion = Union{Maple.TriggerSpikesOriginalUp, Maple.TriggerSpikesOriginalDown, Maple.TriggerSpikesOriginalLeft, Maple.TriggerSpikesOriginalRight}
spikesUnion = Union{normalSpikesUnion, triggerSpikesUnion, triggerSpikesOrigUnion}

triggerSpikeColors = [
    (242, 90, 16, 255) ./ 255,
    (255, 0, 0, 255) ./ 255,
    (242, 16, 103, 255) ./ 255
]

for variant in Maple.spike_types
    for (dir, entity) in entities
        key = "Spikes ($(uppercasefirst(dir)), $(uppercasefirst(variant)))"
        placements[key] = Ahorn.EntityPlacement(
            entity,
            "rectangle",
            Dict{String, Any}(
                "type" => variant
            )
        )
    end

    if variant != "tentacles"
        for (dir, entity) in triggerEntitiesOrig
            key = "Trigger Spikes ($(uppercasefirst(dir)), $(uppercasefirst(variant)))"
            placements[key] = Ahorn.EntityPlacement(
                entity,
                "rectangle",
                Dict{String, Any}(
                    "type" => variant
                )
            )
        end
    end
end

for (dir, entity) in triggerEntities
    key = "Trigger Spikes ($(uppercasefirst(dir)), Dust)"
    placements[key] = Ahorn.EntityPlacement(
        entity,
        "rectangle"
    )
end

Ahorn.editingOptions(entity::normalSpikesUnion) = Dict{String, Any}(
    "type" => Maple.spike_types
)

Ahorn.editingOptions(entity::triggerSpikesOrigUnion) = Dict{String, Any}(
    "type" => String[variant for variant in Maple.spike_types if variant != "tenctacles"]
)

directions = Dict{String, String}(
    "spikesUp" => "up",
    "spikesDown" => "down",
    "spikesLeft" => "left",
    "spikesRight" => "right",

    "triggerSpikesUp" => "up",
    "triggerSpikesDown" => "down",
    "triggerSpikesLeft" => "left",
    "triggerSpikesRight" => "right",

    "triggerSpikesOriginalUp" => "up",
    "triggerSpikesOriginalDown" => "down",
    "triggerSpikesOriginalLeft" => "left",
    "triggerSpikesOriginalRight" => "right",
)

offsets = Dict{String, Tuple{Integer, Integer}}(
    "up" => (4, -4),
    "down" => (4, 4),
    "left" => (-4, 4),
    "right" => (4, 4),
)

triggerOriginalOffsets = Dict{String, Tuple{Integer, Integer}}(
    "up" => (0, 5),
    "down" => (0, -4),
    "left" => (5, 0),
    "right" => (-4, 0),
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

spikeNames = ["spikesDown", "spikesLeft", "spikesRight", "spikesUp"]

triggerNames = ["triggerSpikesDown", "triggerSpikesLeft", "triggerSpikesRight", "triggerSpikesUp"]
triggerRotationOffsets = Dict{String, Tuple{Number, Number}}(
    "up" => (3, -1),
    "right" => (4, 3),
    "down" => (5, 5),
    "left" => (-1, 4),
)

triggerOriginalNames = ["triggerSpikesOriginalDown", "triggerSpikesOriginalLeft", "triggerSpikesOriginalRight", "triggerSpikesOriginalUp"]

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::spikesUnion)
    direction = get(directions, entity.name, "up")
    theta = rotations[direction] - pi / 2

    width = Int(get(entity.data, "width", 0))
    height = Int(get(entity.data, "height", 0))

    x, y = Ahorn.position(entity)
    cx, cy = x + floor(Int, width / 2) - 8 * (direction == "left"), y + floor(Int, height / 2) - 8 * (direction == "up")

    Ahorn.drawArrow(ctx, cx, cy, cx + cos(theta) * 24, cy + sin(theta) * 24, Ahorn.colors.selection_selected_fc, headLength=6)
end

function Ahorn.selection(entity::spikesUnion)
    if haskey(directions, entity.name)
        x, y = Ahorn.position(entity)

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        direction = get(directions, entity.name, "up")
        variant = get(entity.data, "type", "default")

        if variant == "tentacles"
            ox, oy = tentacleSelectionOffsets[direction]

            width = Int(get(entity.data, "width", 16))
            height = Int(get(entity.data, "height", 16))

            return Ahorn.Rectangle(x + ox, y + oy, width, height)

        else
            width = Int(get(entity.data, "width", 8))
            height = Int(get(entity.data, "height", 8))

            ox, oy = offsets[direction]

            return Ahorn.Rectangle(x + ox - 4, y + oy - 4, width, height)
        end
    end
end

function Ahorn.minimumSize(entity::spikesUnion)
    if haskey(directions, entity.name)
        variant = get(entity.data, "type", "default")

        return variant == "tencacles" ? (16, 16) : (8, 8)
    end
end

function Ahorn.resizable(entity::spikesUnion)
    if haskey(directions, entity.name)
        variant = get(entity.data, "type", "default")
        direction = get(directions, entity.name, "up")

        return resizeDirections[direction]
    end
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::spikesUnion)
    if haskey(directions, entity.name)
        variant = entity.name in triggerNames ? "trigger" : get(entity.data, "type", "default")
        direction = get(directions, entity.name, "up")
        triggerOriginalOffset = entity.name in triggerOriginalNames ? triggerOriginalOffsets[direction] : (0, 0)

        if variant == "tentacles"
            width = get(entity.data, "width", 16)
            height = get(entity.data, "height", 16)

            for ox in 0:16:width - 16, oy in 0:16:height - 16
                drawX, drawY = (ox, oy) .+ (16, 16) .* rotationOffsets[direction] .+ triggerOriginalOffset
                Ahorn.drawSprite(ctx, "danger/tentacles00.png", drawX, drawY, rot=rotations[direction])
            end

            if width / 8 % 2 == 1 || height / 8 % 2 == 1
                drawX, drawY = (width - 16, height - 16) .+ (16, 16) .* rotationOffsets[direction] .+ triggerOriginalOffset
                Ahorn.drawSprite(ctx, "danger/tentacles00.png", drawX, drawY, rot=rotations[direction])
            end

        elseif variant == "trigger"
            rng = Ahorn.getSimpleEntityRng(entity)

            width = get(entity.data, "width", 8)
            height = get(entity.data, "height", 8)

            updown = direction == "up" || direction == "down"

            for ox in 0:8:width - 8, oy in 0:8:height - 8
                color1 = rand(rng, triggerSpikeColors)
                color2 = rand(rng, triggerSpikeColors)

                drawX, drawY = (ox, oy) .+ triggerRotationOffsets[direction] .+ triggerOriginalOffset

                Ahorn.drawSprite(ctx, "danger/triggertentacle/wiggle_v06.png", drawX, drawY, rot=rotations[direction], tint=color1)
                Ahorn.drawSprite(ctx, "danger/triggertentacle/wiggle_v03.png", drawX + 3 * updown, drawY + 3 * !updown, rot=rotations[direction], tint=color2)
            end

        else        
            width = get(entity.data, "width", 8)
            height = get(entity.data, "height", 8)

            for ox in 0:8:width - 8, oy in 0:8:height - 8
                drawX, drawY = (ox, oy) .+ offsets[direction] .+ triggerOriginalOffset
                Ahorn.drawSprite(ctx, "danger/spikes/$(variant)_$(direction)00.png", drawX, drawY)
            end
        end
    end
end

end