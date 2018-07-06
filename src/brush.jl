roomTiles(layer::Layer, room::Maple.Room) = layerName(layer) == "fgTiles"? room.fgTiles : room.bgTiles
validTiles(layer::Layer) = layerName(layer) == "fgTiles"? Maple.valid_fg_tiles : Maple.valid_bg_tiles
tileNames(layer::Layer) = layerName(layer) == "fgTiles"? Maple.tile_fg_names : Maple.tile_bg_names

nodeType = Tuple{Number, Number}
edgeType = Tuple{nodeType, nodeType}

function shrinkMatrix(m::Array{Bool, 2})
    h, w = size(m)

    lx, ly = h, w
    hx, hy = 1, 1

    for i in 1:h, j in 1:w
        if m[i, j]
            lx = min(lx, j)
            ly = min(ly, i)
    
            hx = max(hx, j)
            hy = max(hy, i)
        end
    end

    return m[ly:hy, lx:hx], lx, ly
end

function nodesToBrushPixels(nodes::Array{nodeType, 1})
    # Take one pass through to make the output as small as possible
    # Lowest and highest
    lx, ly = nodes[1]
    hx, hy = nodes[1]

    for node in nodes
        x, y = node

        lx = min(lx, x)
        ly = min(ly, y)

        hx = max(hx, x)
        hy = max(hy, y)
    end

    w = hx - lx + 1
    h = hy - ly + 1

    # Generate the output
    res = fill(false, (h, w))

    for node in nodes
        x, y = node

        res[y - ly + 1, x - lx + 1] = true
    end

    return res, lx, ly
end

function brushEdges(a::AbstractArray{Bool})
    res = edgeType[]
    h, w = size(a)

    for y in 1:h, x in 1:w
        # Add edges where there are no adjacent value
        if a[y, x]
            if !get(a, (y - 1, x), false)   
                push!(res, ((x + 1, y), (x, y)))
            end

            if !get(a, (y + 1, x), false)
                push!(res, ((x, y + 1), (x + 1, y + 1)))
            end

            if !get(a, (y, x - 1), false)
                push!(res, ((x, y + 1), (x, y)))
            end

            if !get(a, (y, x + 1), false)
                push!(res, ((x + 1, y), (x + 1, y + 1)))
            end
        end
    end

    return res
end

function connectEdges!(edges::Array{edgeType, 1})
    res = []

    while length(edges) > 0 
        changed = true

        tail, head = pop!(edges)
        nodes = [tail, head]

        while changed
            changed = false

            for (i, edge) in enumerate(edges)
                tail, head = edge

                tailc = tail == nodes[end]
                headc = head == nodes[end]

                if tailc || headc
                    push!(nodes, tailc? head : tail)
                    deleteat!(edges, i)

                    changed = true

                    break
                end
            end
        end

        push!(res, nodes)
    end

    return res
end

mutable struct Brush
    name::String
    pixels::AbstractArray{Bool}
    offset::Tuple{Number, Number}
    nodes::Array{Array{nodeType, 1}, 1}
    rotation::Number

    Brush(name::String, pixels::AbstractArray{Bool}, offset::Tuple{Number, Number}=(1, 1)) = new(name, pixels, offset, connectEdges!(brushEdges(pixels)), 0)
    Brush(name::String, pixels::Array{T, 2}, offset::Tuple{Number, Number}=(1, 1)) where T <: Integer = Brush(name, pixels .!= 0, offset)
end

function rotationOffset(ctx::CairoContext, brush::Brush)
    bh, bw = size(brush.pixels)
    rotation = brush.rotation

    if rotation == 0
        translate(ctx, 0, 0)

    elseif rotation == 1
        translate(ctx, 0, -bh + 1)

    elseif rotation == 2
        translate(ctx, -bw + 1, -bh + 1)

    elseif rotation == 3
        translate(ctx, -bw + 1, 0)
    end
end

function drawBrush(brush::Brush, layer::Layer, x::Number, y::Number)
    ctx = creategc(layer.surface)

    ox, oy = brush.offset

    Cairo.save(ctx)

    scale(ctx, 8, 8)
    translate(ctx, x + ox - 1.5, y + oy - 1.5)
    rotate(ctx, brush.rotation * pi / 2)
    translate(ctx, -1.5, -1.5)
    rotationOffset(ctx, brush)

    for nodes in brush.nodes
        drawLines(ctx, nodes, colors.brush_bc, filled=true, fc=colors.brush_fc)
    end

    restore(ctx)
end

function applyBrush!(brush::Brush, tiles::Maple.Tiles, material::Char, x::Number, y::Number)
    brushPixels = rotr90(brush.pixels, brush.rotation)
    tilesData = tiles.data

    bh, bw = size(brushPixels)
    th, tw = size(tilesData)
    ox, oy = brush.offset

    for j in 1:bh, i in 1:bw
        ty, tx = j + y + oy - 2, i + x + ox - 2

        # Manual slice assignment
        # Brushes can be applied "off screen"
        if 1 <= ty <= th && 1 <= tx <= tw
            if brushPixels[j, i]
                tilesData[ty, tx] = material
            end
        end
    end
end

function applyBrush!(brush::Brush, tiles::Maple.Tiles, materials::Array{Char, 2}, x::Number, y::Number)
    brushPixels = rotr90(brush.pixels, brush.rotation)
    #materials = rotr90(materials, brush.rotation)
    tilesData = tiles.data

    bh, bw = size(brushPixels)
    th, tw = size(tilesData)
    ox, oy = brush.offset

    for j in 1:bh, i in 1:bw
        ty, tx = j + y - oy, i + x - ox

        # Manual slice assignment
        # Brushes can be applied "off screen"
        if 1 <= ty <= th && 1 <= tx <= tw
            if brushPixels[j, i]
                tilesData[ty, tx] = materials[j, i]
            end
        end
    end
end
