roomTiles(layer::Layer, room::Maple.Room) = layerName(layer) == "fgTiles" ? room.fgTiles : room.bgTiles

function validTiles(layer::String, removeTemplate::Bool=true) 
    meta = layer == "fgTiles" ? fgTilerMeta : bgTilerMeta

    res = collect(keys(meta.paths))
    push!(res, '0')

    if removeTemplate
        index = findfirst(isequal('z'), res)
        if index !== nothing
            deleteat!(res, index)
        end
    end

    sort!(res)

    return res
end

validTiles(layer::Layer, removeTemplate::Bool=true) = validTiles(layerName(layer), removeTemplate)

function tileNames(name::String)
    meta = name == "fgTiles" ? fgTilerMeta : bgTilerMeta
    res = Dict{Any, Any}(
        '0' => "Air",
        "Air" => '0'
    )

    for (id, path) in meta.paths
        name = humanizeVariableName(splitdir(path)[2])

        if startswith(name, "Bg ")
            name = name[4:end]
        end

        res[name] = id
        res[id] = name
    end

    return res
end

tileNames(layer::Layer) = tileNames(layerName(layer))

function getBrushMaterialsNames(name::String, sortByDisplayName::Bool=true)
    loadXMLMeta(false)

    validTileIds = validTiles(name)
    tileTileNames = tileNames(name)

    displayNames = [tileTileNames[mat] for mat in validTileIds]

    if sortByDisplayName
        sort!(displayNames)
    end

    return displayNames
end

getBrushMaterialsNames(layer::Layer, sortByDisplayName::Bool=true) = getBrushMaterialsNames(layerName(layer), sortByDisplayName)

const nodeType = Tuple{Number, Number}
const edgeType = Tuple{nodeType, nodeType}

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
    lx = ly = typemax(Int)
    hx = hy = typemin(Int)

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
                    push!(nodes, tailc ? head : tail)
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

function drawBrush(brush::Brush, layer::Layer, x::Number, y::Number, thickness::Int=2)
    ctx = getSurfaceContext(layer.surface)

    if ctx.ptr != C_NULL
        ox, oy = brush.offset

        Cairo.save(ctx)

        scale(ctx, 8, 8)
        translate(ctx, x + ox - 1.5, y + oy - 1.5)
        rotate(ctx, brush.rotation * pi / 2)
        translate(ctx, -1.5, -1.5)
        rotationOffset(ctx, brush)

        for nodes in deepcopy.(brush.nodes)
            # Fixes weird off by one error in Cairo paths
            # 1 / 8 is one "pixel", taking into account the (8, 8) scale
            # This should be good enough, but might look bad at non default stroke thickness

            extend = ceil(thickness / 2)
            nodes[end] = nodes[end] .+ (extend / 8, extend / 8) .* sign.(nodes[end] .- nodes[end - 1])
            drawLines(ctx, nodes, colors.brush_bc, filled=true, fc=colors.brush_fc, thickness=thickness)
        end

        restore(ctx)
    end
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

function findFill(tiles::Array{Char, 2}, x::Number, y::Number)
    target = tiles[y, x]
    stack = Tuple{Number, Number}[(x, y)]

    h, w = size(tiles)

    res = fill(false, (h, w))

    while length(stack) > 0
        tx, ty = pop!(stack)

        if 1 <=tx <= w && 1 <= ty <= h && !res[ty, tx]
            if target == tiles[ty, tx]
                res[ty, tx] = true

                push!(stack, (tx - 1, ty))
                push!(stack, (tx, ty - 1))
                push!(stack, (tx + 1, ty))
                push!(stack, (tx, ty + 1))
            end
        end
    end

    return res
end