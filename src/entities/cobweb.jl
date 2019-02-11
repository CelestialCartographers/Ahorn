module Cobweb

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Cobweb" => Ahorn.EntityPlacement(
        Maple.Cobweb,
        "line"
    )
)

cobwebColorHex = "696A6A"
cobwebColor = (41, 42, 42, 1) ./ (255, 255, 255, 1)
cobwebColorSelected = (Ahorn.colors.selection_selected_fc)

function renderCobweb(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Cobweb, color::Ahorn.colorTupleType=cobwebColor)
    x, y = Ahorn.position(entity)

    start = (x, y)
    nodes = get(entity.data, "nodes", [start])
    stop = nodes[1]

    baseCurve = Ahorn.SimpleCurve(start, stop, (start .+ stop) ./ 2 .+ (0, 4))
    middle = Ahorn.getPoint(baseCurve, 0.5)

    for node in nodes
        curve = Ahorn.SimpleCurve(middle, node, (middle .+ node) ./ 2 .+ (0, 4))
        Ahorn.drawSimpleCurve(ctx, curve, color, thickness=1)
    end

    curve = Ahorn.SimpleCurve(middle, start, (middle .+ start) ./ 2 .+ (0, 4))
    Ahorn.drawSimpleCurve(ctx, curve, color, thickness=1)
end

Ahorn.nodeLimits(entity::Maple.Cobweb) = 1, -1

function Ahorn.selection(entity::Maple.Cobweb)
    nodes = get(entity.data, "nodes", ())
    x, y = Ahorn.position(entity)

    res = Ahorn.Rectangle[Ahorn.Rectangle(x - 4, y - 4, 8, 8)]
    
    for node in nodes
        nx, ny = node

        push!(res, Ahorn.Rectangle(nx - 4, ny - 4, 8, 8))
    end

    return res
end

Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Cobweb) = renderCobweb(ctx, entity, cobwebColorSelected)

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Cobweb, room::Maple.Room)
    # Make sure Alpha is 1
    rawColor = Ahorn.argb32ToRGBATuple(parse(Int, get(entity.data, "color", cobwebColorHex), base=16))[1:3] ./ 255
    color = (rawColor..., 1.0)
            
    renderCobweb(ctx, entity, color)
end

end