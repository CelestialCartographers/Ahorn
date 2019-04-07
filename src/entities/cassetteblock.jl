module CassetteBlock

using ..Ahorn, Maple

colorNames = Dict{String, Int}(
    "Blue" => 0,
    "Rose" => 1,
    "Bright Sun" => 2,
    "Malachite" => 3
)

const placements = Ahorn.PlacementDict(
    "Cassette Block ($index - $color)" => Ahorn.EntityPlacement(
        Maple.CassetteBlock,
        "rectangle",
        Dict{String, Any}(
            "index" => index,
        )
    ) for (color, index) in colorNames
)

Ahorn.editingOptions(entity::Maple.CassetteBlock) = Dict{String, Any}(
    "index" => colorNames
)


Ahorn.minimumSize(entity::Maple.CassetteBlock) = 16, 16
Ahorn.resizable(entity::Maple.CassetteBlock) = true, true

Ahorn.selection(entity::Maple.CassetteBlock) = Ahorn.getEntityRectangle(entity)

colors = Dict{Integer, Ahorn.colorTupleType}(
    1 => (240, 73, 190, 255) ./ 255,
	2 => (252, 220, 58, 255) ./ 255,
	3 => (56, 224, 78, 255) ./ 255,
)

defaultColor = (73, 170, 240, 255) ./ 255
borderMultiplier = (0.9, 0.9, 0.9, 1)

frame = "objects/cassetteblock/solid"

function getCassetteBlockRectangles(room::Maple.Room)
    entities = filter(e -> e.name == "cassetteBlock", room.entities)
    rects = Dict{Integer, Array{Ahorn.Rectangle, 1}}()

    for e in entities
        index = get(e.data, "index", 0)

        if !haskey(rects, index)
            rects[index] = Ahorn.Rectangle[]
        end
        
        push!(rects[index], Ahorn.Rectangle(
            Int(get(e.data, "x", 0)),
            Int(get(e.data, "y", 0)),
            Int(get(e.data, "width", 8)),
            Int(get(e.data, "height", 8))
        ))
    end
        
    return rects
end

# Is there a casette block we should connect to at the offset?
function notAdjacent(entity::Maple.CassetteBlock, ox::Integer, oy::Integer, rects::Array{Ahorn.Rectangle, 1})
    x, y = Ahorn.position(entity)
    rect = Ahorn.Rectangle(x + ox + 4, y + oy + 4, 1, 1)

    return !any(Ahorn.checkCollision.(rects, Ref(rect)))
end

function drawCassetteBlock(ctx::Ahorn.Cairo.CairoContext, entity::Maple.CassetteBlock, room::Maple.Room)
    cassetteBlockRectangles = getCassetteBlockRectangles(room)

    x, y = Ahorn.position(entity)

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    tileWidth = ceil(Int, width / 8)
    tileHeight = ceil(Int, height / 8)

    index = Int(get(entity.data, "index", 0))
    color = get(colors, index, defaultColor)

    rect = Ahorn.Rectangle(x, y, width, height)
    rects = get(cassetteBlockRectangles, index, Ahorn.Rectangle[])

    if !(rect in rects)
        push!(rects, rect)
    end

    for x in 1:tileWidth, y in 1:tileHeight
        drawX, drawY = (x - 1) * 8, (y - 1) * 8

        closedLeft = !notAdjacent(entity, drawX - 8, drawY, rects)
        closedRight = !notAdjacent(entity, drawX + 8, drawY, rects)
        closedUp = !notAdjacent(entity, drawX, drawY - 8, rects)
        closedDown = !notAdjacent(entity, drawX, drawY + 8, rects)
        completelyClosed = closedLeft && closedRight && closedUp && closedDown

        if completelyClosed
            if notAdjacent(entity, drawX + 8, drawY - 8, rects)
                Ahorn.drawImage(ctx, frame, drawX, drawY, 24, 0, 8, 8, tint=color)

            elseif notAdjacent(entity, drawX - 8, drawY - 8, rects)
                Ahorn.drawImage(ctx, frame, drawX, drawY, 24, 8, 8, 8, tint=color)

            elseif notAdjacent(entity, drawX + 8, drawY + 8, rects)
                Ahorn.drawImage(ctx, frame, drawX, drawY, 24, 16, 8, 8, tint=color)

            elseif notAdjacent(entity, drawX - 8, drawY + 8, rects)
                Ahorn.drawImage(ctx, frame, drawX, drawY, 24, 24, 8, 8, tint=color)

            else
                Ahorn.drawImage(ctx, frame, drawX, drawY, 8, 8, 8, 8, tint=color)
            end

        else
            if closedLeft && closedRight && !closedUp && closedDown
                Ahorn.drawImage(ctx, frame, drawX, drawY, 8, 0, 8, 8, tint=color)

            elseif closedLeft && closedRight && closedUp && !closedDown
                Ahorn.drawImage(ctx, frame, drawX, drawY, 8, 16, 8, 8, tint=color)

            elseif closedLeft && !closedRight && closedUp && closedDown
                Ahorn.drawImage(ctx, frame, drawX, drawY, 16, 8, 8, 8, tint=color)

            elseif !closedLeft && closedRight && closedUp && closedDown
                Ahorn.drawImage(ctx, frame, drawX, drawY, 0, 8, 8, 8, tint=color)

            elseif closedLeft && !closedRight && !closedUp && closedDown
                Ahorn.drawImage(ctx, frame, drawX, drawY, 16, 0, 8, 8, tint=color)

            elseif !closedLeft && closedRight && !closedUp && closedDown
                Ahorn.drawImage(ctx, frame, drawX, drawY, 0, 0, 8, 8, tint=color)

            elseif !closedLeft && closedRight && closedUp && !closedDown
                Ahorn.drawImage(ctx, frame, drawX, drawY, 0, 16, 8, 8, tint=color)

            elseif closedLeft && !closedRight && closedUp && !closedDown
                Ahorn.drawImage(ctx, frame, drawX, drawY, 16, 16, 8, 8, tint=color)
            end
        end
    end
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.CassetteBlock, room::Maple.Room) = drawCassetteBlock(ctx, entity, room)

end