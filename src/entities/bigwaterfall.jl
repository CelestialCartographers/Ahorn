module BigWaterfall

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Big Waterfall (FG)" => Ahorn.EntityPlacement(
        Maple.BigWaterfall,
        "rectangle",
        Dict{String, Any}(
            "layer" => "FG"
        )
    ),
    "Big Waterfall (BG)" => Ahorn.EntityPlacement(
        Maple.BigWaterfall,
        "rectangle",
        Dict{String, Any}(
            "layer" => "BG"
        )
    ),
)

const fillColor = Ahorn.XNAColors.LightBlue .* 0.3
const surfaceColor = Ahorn.XNAColors.LightBlue .* 0.8

const waterSegmentLeftMatrix = [
    1 1 1 0 1 0;
    1 1 1 0 1 0;
    1 1 1 0 1 0;
    1 1 1 1 0 1;
    1 1 1 1 0 1;
    1 1 1 1 0 1;
    1 1 1 1 0 1;
    1 1 1 1 0 1;
    1 1 1 1 0 1;
    1 1 1 1 0 1;
    1 1 1 1 0 1;
    1 1 1 0 1 0;
    1 1 1 0 1 0;
    1 1 0 1 0 0;
    1 1 0 1 0 0;
    1 1 0 1 0 0;
    1 1 0 1 0 0;
    1 1 0 1 0 0;
    1 1 0 1 0 0;
    1 1 0 1 0 0;
    1 1 0 1 0 0;
]

const waterSegmentLeft = Ahorn.matrixToSurface(
    waterSegmentLeftMatrix,
    [
        fillColor,
        surfaceColor
    ]
)

const waterSegmentRightMatrix = [
    0 1 0 1 1 1;
    0 1 0 1 1 1;
    0 1 0 1 1 1;
    0 0 1 0 1 1;
    0 0 1 0 1 1;
    0 0 1 0 1 1;
    0 0 1 0 1 1;
    0 0 1 0 1 1;
    0 0 1 0 1 1;
    0 0 1 0 1 1;
    0 0 1 0 1 1;
    0 1 0 1 1 1;
    0 1 0 1 1 1;
    1 0 1 1 1 1;
    1 0 1 1 1 1;
    1 0 1 1 1 1;
    1 0 1 1 1 1;
    1 0 1 1 1 1;
    1 0 1 1 1 1;
    1 0 1 1 1 1;
    1 0 1 1 1 1;
]

const waterSegmentRight = Ahorn.matrixToSurface(
    waterSegmentRightMatrix,
    [
        fillColor,
        surfaceColor
    ]
)

Ahorn.minimumSize(entity::Maple.BigWaterfall) = 8, 8
Ahorn.resizable(entity::Maple.BigWaterfall) = true, true

Ahorn.selection(entity::Maple.BigWaterfall) = Ahorn.getEntityRectangle(entity)

Ahorn.editingOptions(entity::Maple.BigWaterfall) = Dict{String, Any}(
    "layer" => String["FG", "BG"]
)

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.BigWaterfall, room::Maple.Room)
    x = Int(get(entity.data, "x", 0))
    y = Int(get(entity.data, "y", 0))

    width = Int(get(entity.data, "width", 16))
    height = Int(get(entity.data, "height", 64))

    segmentHeightLeft, segmentWidthLeft = size(waterSegmentLeftMatrix)
    segmentHeightRight, segmentWidthRight = size(waterSegmentRightMatrix)

    Ahorn.Cairo.save(ctx)

    Ahorn.rectangle(ctx, 0, 0, width, height)
    Ahorn.clip(ctx)

    for i in 0:segmentHeightLeft:ceil(Int, height / segmentHeightLeft) * segmentHeightLeft
        Ahorn.drawImage(ctx, waterSegmentLeft, 0, i)
        Ahorn.drawImage(ctx, waterSegmentRight, width - segmentWidthRight, i)
    end

    # Drawing a rectangle normally doesn't guarantee that its the same color as above
    if height >= 0 && width >= segmentWidthLeft + segmentWidthRight
        fillRectangle = Ahorn.matrixToSurface(fill(0, (height, width - segmentWidthLeft - segmentWidthRight)), [fillColor])
        Ahorn.drawImage(ctx, fillRectangle, segmentWidthLeft, 0)
    end
    
    Ahorn.restore(ctx)
end

end