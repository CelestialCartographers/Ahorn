module Lightning

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Lightning" => Ahorn.EntityPlacement(
        Maple.Lightning,
        "rectangle"
    )
)

const lightningFillColor = (0.55, 0.97, 0.96, 0.4)
const lightningBorderColor = (0.99, 0.96, 0.47, 1.0)

Ahorn.nodeLimits(entity::Maple.Lightning) = 0, 1

Ahorn.minimumSize(entity::Maple.Lightning) = 8, 8
Ahorn.resizable(entity::Maple.Lightning) = true, true

function Ahorn.selection(entity::Maple.Lightning)
    x, y = Ahorn.position(entity)

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))

    nodes = get(entity.data, "nodes", ())
    if isempty(nodes)
        return Ahorn.Rectangle(x, y, width, height)

    else
        nx, ny = Int.(nodes[1])
        return [Ahorn.Rectangle(x, y, width, height), Ahorn.Rectangle(nx, ny, width, height)]
    end
end

function renderLightningBlock(ctx::Ahorn.Cairo.CairoContext, x::Number, y::Number, width::Number, height::Number)
    Ahorn.Cairo.save(ctx)

    Ahorn.set_antialias(ctx, 1)
    Ahorn.set_line_width(ctx, 1)

    Ahorn.drawRectangle(ctx, x, y, width, height, lightningFillColor, lightningBorderColor)

    Ahorn.restore(ctx)
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Lightning)
    x, y = Ahorn.position(entity)
    nodes = get(entity.data, "nodes", ())

    width = Int(get(entity.data, "width", 8))
    height = Int(get(entity.data, "height", 8))
    
    if !isempty(nodes)
        nx, ny = Int.(nodes[1])

        cox, coy = floor(Int, width / 2), floor(Int, height / 2)

        renderLightningBlock(ctx, nx, ny, width, height)
        Ahorn.drawArrow(ctx, x + cox, y + coy, nx + cox, ny + coy, Ahorn.colors.selection_selected_fc, headLength=6)
    end
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Lightning, room::Maple.Room)
    x = Int(get(entity.data, "x", 0))
    y = Int(get(entity.data, "y", 0))

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    renderLightningBlock(ctx, 0, 0, width, height)
end

end