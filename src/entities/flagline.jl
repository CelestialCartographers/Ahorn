module Flagline

using ..Ahorn, Maple
using Random

const placements = Ahorn.PlacementDict(
    "Clothes Line" => Ahorn.EntityPlacement(
        Maple.ClothesLine,
        "line"
    ),
    "Cliffside Flags" => Ahorn.EntityPlacement(
        Maple.CliffFlags,
        "line"
    ),
)

const flagLineUnion = Union{Maple.ClothesLine, Maple.CliffFlags}

Ahorn.nodeLimits(entity::flagLineUnion) = 1, 1

function Ahorn.selection(entity::flagLineUnion)
    nodes = get(entity.data, "nodes", ())
    x, y = Ahorn.position(entity)

    res = Ahorn.Rectangle[Ahorn.Rectangle(x - 4, y - 4, 8, 8)]
    
    for node in nodes
        nx, ny = node

        push!(res, Ahorn.Rectangle(nx - 4, ny - 4, 8, 8))
    end

    return res
end

const droopAmount = 0.6
const selectedColor = Ahorn.colors.selection_selected_fc

const clothesLineColor = (128, 128, 163, 1) ./ (255, 255, 255, 1)
const clothesPinColor = (128, 128, 128, 1) ./ (255, 255, 255, 1)
const clothesColors = Ahorn.colorTupleType[
    (13, 46, 107, 1) ./ (255, 255, 255, 1),
    (61, 38, 136, 1) ./ (255, 255, 255, 1),
    (79, 110, 157, 1) ./ (255, 255, 255, 1),
    (71, 25, 74, 1) ./ (255, 255, 255, 1)
]
const clothesMinFlagHeight = 8
const clothesMaxFlagHeight = 20
const clothesMinFlagLength = 8
const clothesMaxFlagLength = 16
const clothesMinSpace = 2
const clothesMaxSpace = 8

const cliffLineColor = (128, 128, 163, 1) ./ (255, 255, 255, 1)
const cliffPinColor = (128, 128, 128, 1) ./ (255, 255, 255, 1)
const cliffColors = Ahorn.colorTupleType[
    (216, 95, 47, 1) ./ (255, 255, 255, 1),
    (216, 47, 99, 1) ./ (255, 255, 255, 1),
    (47, 216, 162, 1) ./ (255, 255, 255, 1),
    (216, 214, 47, 1) ./ (255, 255, 255, 1)
]
const cliffMinFlagHeight = 10
const cliffMaxFlagHeight = 10
const cliffMinFlagLength = 10
const cliffMaxFlagLength = 10
const cliffMinSpace = 2
const cliffMaxSpace = 8

const flaglineUnion = Union{Maple.ClothesLine, Maple.CliffFlags}

function renderFlagLine(ctx::Ahorn.Cairo.CairoContext, entity::flaglineUnion, lineColor::Ahorn.colorTupleType, pinColor::Ahorn.colorTupleType, colors::Array{Ahorn.colorTupleType, 1},
        minFlagHeight::Integer, maxFlagHeight::Integer, minFlagLength::Integer, maxFlagLength::Integer, minSpace::Integer, maxSpace::Integer)
    rng = Ahorn.getSimpleEntityRng(entity)
    x, y = Ahorn.position(entity)

    start = (x, y)
    stop = get(entity.data, "nodes", [start])[1]
    control = (start .+ stop) ./ 2 .+ (0, 10)

    startPoint = start[1] < stop[1] ? start : stop
    stopPoint = start[1] < stop[1] ? stop : start
    lastPoint = startPoint

    progress = 0
    curveLength = sqrt(sum((start .- stop) .^ 2))

    drawFlag = false

    baseCurve = Ahorn.SimpleCurve(startPoint, stopPoint, control)

    # Fix extra small line being wonky
    # Still looks bad for flagless longer lines
    if curveLength <= 16
        Ahorn.drawSimpleCurve(ctx, baseCurve, lineColor, thickness=1)

        return true
    end

    Ahorn.Cairo.save(ctx)

    Ahorn.set_antialias(ctx, 1)
    Ahorn.set_line_width(ctx, 1)
    Ahorn.fill_preserve(ctx)

    while progress < 1
        color = rand(rng, colors)
        hightlightColor = color .+ (0.1, 0.1, 0.1, 0)
        height = rand(rng, minFlagHeight:maxFlagHeight)
        length = rand(rng, minFlagLength:maxFlagLength)
        step = rand(rng, minSpace:maxSpace)

        progress += (drawFlag ? length : step) / curveLength

        point = Ahorn.getPoint(baseCurve, progress)

        Ahorn.move_to(ctx, lastPoint...)
        Ahorn.line_to(ctx, point...)
        Ahorn.setSourceColor(ctx, lineColor)
        Ahorn.stroke(ctx)

        if progress < 1 && drawFlag
            droop = length * droopAmount

            flagCurve = Ahorn.SimpleCurve(lastPoint, point, (lastPoint .+ point) ./ 2 .+ (0, droopAmount * length))
            prevFlagPoint = Ahorn.getPoint(flagCurve, 1 / length)
            
            Ahorn.setSourceColor(ctx, color)

            for i in 0:length
                flagPoint = Ahorn.getPoint(flagCurve, i / length)

                if flagPoint[1] > prevFlagPoint[1] 
                    segmentWidth = min(floor(Int, flagPoint[1] - prevFlagPoint[1]), point[1] - flagPoint[1])
    
                    Ahorn.rectangle(ctx, flagPoint[1], flagPoint[2], segmentWidth, height - 1)
                end

                prevFlagPoint = flagPoint
            end

            Ahorn.stroke(ctx)

            Ahorn.setSourceColor(ctx, hightlightColor)
            Ahorn.rectangle(ctx, lastPoint[1], lastPoint[2], 0, height - 1)
            Ahorn.rectangle(ctx, point[1], point[2], 0, height - 1)
            Ahorn.stroke(ctx)

            Ahorn.setSourceColor(ctx, pinColor)
            Ahorn.rectangle(ctx, lastPoint[1], lastPoint[2] - 1, 0, 3)
            Ahorn.rectangle(ctx, point[1], point[2] - 1, 0, 3)
            Ahorn.stroke(ctx)
        end

        lastPoint = point
        drawFlag = !drawFlag
    end

    Ahorn.move_to(ctx, lastPoint...)
    Ahorn.line_to(ctx, stopPoint...)
    Ahorn.setSourceColor(ctx, lineColor)
    Ahorn.stroke(ctx)

    Ahorn.Cairo.restore(ctx)
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.ClothesLine)
    renderFlagLine(ctx, entity, selectedColor, clothesPinColor, clothesColors, clothesMinFlagHeight, clothesMaxFlagHeight,
            clothesMinFlagLength, clothesMaxFlagLength, clothesMinSpace, clothesMaxSpace)
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.CliffFlags)
    renderFlagLine(ctx, entity, selectedColor, cliffPinColor, cliffColors, cliffMinFlagHeight, cliffMaxFlagHeight,
            cliffMinFlagLength, cliffMaxFlagLength, cliffMinSpace, cliffMaxSpace)
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.ClothesLine, room::Maple.Room)
    renderFlagLine(ctx, entity, clothesLineColor, clothesPinColor, clothesColors, clothesMinFlagHeight, clothesMaxFlagHeight,
            clothesMinFlagLength, clothesMaxFlagLength, clothesMinSpace, clothesMaxSpace)
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.CliffFlags, room::Maple.Room)
    renderFlagLine(ctx, entity, cliffLineColor, cliffPinColor, cliffColors, cliffMinFlagHeight, cliffMaxFlagHeight,
            cliffMinFlagLength, cliffMaxFlagLength, cliffMinSpace, cliffMaxSpace)
end

end