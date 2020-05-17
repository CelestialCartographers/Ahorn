using LightXML

struct AnimatedTile
    name::String
    path::String

    origX::Number
    origY::Number

    posX::Number
    posY::Number

    delay::Number
end

const Mask = Array{Int, 2}

# Convert mask string into a 3x3 matrix
function getMaskFromString(s::String)
    data = replace(replace(s, "-" => ""), "x" => "2")

    return Mask(transpose(reshape(parse.(Int, (collect(data))), (3, 3))))
end

function sortScore(mask::Mask)
    return length(filter(v -> v == 2, mask))
end

# Get quads for a given mask
function convertTileString(s::String)
    parts = split(s, ";")
    res = Coord[]

    for part in parts
        x, y = parse.(Int, split(part, ","))

        push!(res, Coord(x, y))
    end

    return res
end

function loadAnimatedTilesXML(fn::String)
    xdoc = parse_file(fn)
    xroot = root(xdoc)

    animatedTiles = AnimatedTile[]

    for elem in child_elements(xroot)
        push!(animatedTiles, AnimatedTile(
            attribute(elem, "name"),
            attribute(elem, "path"),

            parseNumber(attribute(elem, "origX")),
            parseNumber(attribute(elem, "origY")),

            parseNumber(attribute(elem, "posX")),
            parseNumber(attribute(elem, "posY")),

            parseNumber(attribute(elem, "delay"))
        ))
    end

    return animatedTiles
end

struct Coord
    x::Int
    y::Int
end

struct MaskData
    mask::Mask
    coords::Array{Coord, 1}
    sprites::String
end

function loadTilesetXML(fn::String)
    xdoc = parse_file(fn)
    xroot = root(xdoc)

    paths = Dict{Char, String}()
    masks = Dict{Char, Array{MaskData, 1}}()
    padding = Dict{Char, Array{Coord, 1}}()
    center = Dict{Char, Array{Coord, 1}}()
    ignores = Dict{Char, Set{Char}}()

    orderedElements = sort(collect(child_elements(xroot)), by=set -> attribute(set, "copy") !== nothing)

    for set in orderedElements
        id = attribute(set, "id")[1] # Char doesn't work on 1 length string?
        path = attribute(set, "path")
        copyTileset = attribute(set, "copy")
        ignore = attribute(set, "ignores")

        paths[id] = "tilesets/$path"

        if ignore !== nothing
            ignores[id] = Set{Char}(ignore)
        end

        if copyTileset !== nothing
            tilesetId = copyTileset[1]
            padding[id] = deepcopy(padding[tilesetId])
            center[id] = deepcopy(center[tilesetId])
            masks[id] = deepcopy(masks[tilesetId])
        end

        currMasks = MaskData[]

        for c in child_elements(set)
            mask = attribute(c, "mask")
            tilesString = attribute(c, "tiles")
            quads = convertTileString(tilesString)

            if mask == "padding"
                padding[id] = quads

            elseif mask == "center"
                center[id] = quads

            else
                sprites = attribute(c, "sprites")
                push!(currMasks, MaskData(
                    getMaskFromString(mask),
                    quads,
                    isa(sprites, String) ? sprites : ""
                ))
            end
        end

        if !isempty(currMasks)
            masks[id] = currMasks
            sort!(masks[id], by=m -> sortScore(m.mask), rev=false)
        end
    end

    return paths, masks, padding, center, ignores
end

struct TilerMeta
    paths::Dict{Char, String}
    masks::Dict{Char, Array{MaskData, 1}}
    paddings::Dict{Char, Array{Coord, 1}}
    centers::Dict{Char, Array{Coord, 1}}
    ignores::Dict{Char, Set{Char}}
end

TilerMeta(s::String) = TilerMeta(loadTilesetXML(s)...)

fgTilerMeta = nothing
bgTilerMeta = nothing
animatedTilesMeta = nothing

function loadFgTilerMeta(side::Union{Side, Nothing}, fn::String, loadDefault::Bool=false)
    path = joinpath(storageDirectory, "XML", "ForegroundTiles.xml")

    if side !== nothing && !loadDefault
        meta = get(Dict{String, Any}, side.data, "meta")
        metaPath = get(meta, "ForegroundTiles", "")

        hasRoot, modRoot = getModRoot(fn)
        xmlPath = joinpath(modRoot, metaPath)

        if !isempty(metaPath) && hasRoot
            path = xmlPath
        end
    end

    try
        global fgTilerMeta = TilerMeta(path)
    
    catch e
        if !loadDefault
            println(Base.stderr, "Failed to load custom ForegroundTiles XML")
            println(Base.stderr, e)

            for (exc, bt) in Base.catch_stack()
                showerror(Base.stderr, exc, bt)
                println()
            end

            loadFgTilerMeta(side, fn, true)
        end
    end
end

function loadBgTilerMeta(side::Union{Side, Nothing}, fn::String, loadDefault::Bool=false)
    path = joinpath(storageDirectory, "XML", "BackgroundTiles.xml")

    if side !== nothing && !loadDefault
        meta = get(Dict{String, Any}, side.data, "meta")
        metaPath = get(meta, "BackgroundTiles", "")

        hasRoot, modRoot = getModRoot(fn)
        xmlPath = joinpath(modRoot, metaPath)

        if !isempty(metaPath) && hasRoot
            path = xmlPath
        end
    end

    try
        global bgTilerMeta = TilerMeta(path)

    catch e
        if !loadDefault
            println(Base.stderr, "Failed to load custom BackgroundTiles XML")
            println(Base.stderr, e)

            for (exc, bt) in Base.catch_stack()
                showerror(Base.stderr, exc, bt)
                println()
            end

            loadBgTilerMeta(side, fn, true)
        end
    end
end

function loadAnimatedTilesMeta(side::Union{Side, Nothing}, fn::String, loadDefault::Bool=false)
    path = joinpath(storageDirectory, "XML", "AnimatedTiles.xml")

    if side !== nothing && !loadDefault
        meta = get(Dict{String, Any}, side.data, "meta")
        metaPath = get(meta, "AnimatedTiles", "")

        hasRoot, modRoot = getModRoot(fn)
        xmlPath = joinpath(modRoot, metaPath)

        if !isempty(metaPath) && hasRoot
            path = xmlPath
        end
    end

    try
        global animatedTilesMeta = loadAnimatedTilesXML(path)

    catch e
        if !loadDefault
            println(Base.stderr, "Failed to load custom AnimatedTiles XML")
            println(Base.stderr, e)

            for (exc, bt) in Base.catch_stack()
                showerror(Base.stderr, exc, bt)
                println()
            end

            loadAnimatedTilesMeta(side, fn, true)
        end
    end
end

function loadXMLMeta()
    side = loadedState.side
    filename = loadedState.filename

    loadFgTilerMeta(side, filename)
    loadBgTilerMeta(side, filename)
    loadAnimatedTilesMeta(side, filename)
end

function getTile(tiles::Tiles, x::Int, y::Int)
    return get(tiles.data, (y, x), ' ')
end

function checkPadding(tiles::Tiles, x::Int, y::Int)
    # Checks for '0' even though getTile might return ' '
    # This is due to quirks/special flags in the actuall autotiler
    return getTile(tiles, x - 2, y) == '0' || getTile(tiles, x + 2, y) == '0' || getTile(tiles, x, y - 2) == '0' || getTile(tiles, x, y + 2) == '0'
end

const ignoresDefault = Set{Char}()

# Return the "mask" value for a tile
function checkTile(value::Char, target::Char, ignore::Set{Char}=ignoresDefault)
    return !(target == '0' || target in ignore || ('*' in ignore && value != target))
end

# Unrolled for performance
# We never need to check 5, otherwise we wouldn't be in this mask check
function checkMask(mask::Mask, adj::Array{Bool, 1})
    return @inbounds !(
        adj[1] != mask[1] && mask[1] != 2 ||
        adj[2] != mask[2] && mask[2] != 2 ||
        adj[3] != mask[3] && mask[3] != 2 ||
        adj[4] != mask[4] && mask[4] != 2 ||
        adj[6] != mask[6] && mask[6] != 2 ||
        adj[7] != mask[7] && mask[7] != 2 ||
        adj[8] != mask[8] && mask[8] != 2 ||
        adj[9] != mask[9] && mask[9] != 2
    )
end

function getIfInboundsKnownSize(data::Array{Char, 2}, y::Int, x::Int, height::Int, width::Int, default::Char='0')::Char
    if 1 <= y <= height && 1 <= x <= width
        return @inbounds data[y, x]

    else
        return default
    end
end

function getAdjacencyArray(data::Array{Char, 2}, y::Int, x::Int, height::Int, width::Int, default::Char, ignores::Set{Char})::Array{Bool, 1}
    return Bool[
        checkTile(default, getIfInboundsKnownSize(data, y - 1, x - 1, height, width, default), ignores),
        checkTile(default, getIfInboundsKnownSize(data, y, x - 1, height, width, default), ignores),
        checkTile(default, getIfInboundsKnownSize(data, y + 1, x - 1, height, width, default), ignores),

        checkTile(default, getIfInboundsKnownSize(data, y - 1, x, height, width, default), ignores),
        true,
        checkTile(default, getIfInboundsKnownSize(data, y + 1, x, height, width, default), ignores),
    
        checkTile(default, getIfInboundsKnownSize(data, y - 1, x + 1, height, width, default), ignores),
        checkTile(default, getIfInboundsKnownSize(data, y, x + 1, height, width, default), ignores),
        checkTile(default, getIfInboundsKnownSize(data, y + 1, x + 1, height, width, default), ignores)
    ]
end

const defaultPaddingCoords = Coord[Coord(0, 0)]
const maskDataDefault = MaskData[]

function getMaskQuads(x::Int, y::Int, tiles::Tiles, meta::TilerMeta)
    data = tiles.data
    height, width = size(data)
    value = @inbounds tiles.data[y, x]

    masks = get(meta.masks, value, maskDataDefault)
    ignores = get(meta.ignores, value, ignoresDefault)

    adjacent = getAdjacencyArray(data, y, x, height, width, value, ignores)

    for data in masks
        if checkMask(data.mask, adjacent)
            return data.coords, data.sprites
        end
    end

    if checkPadding(tiles, x, y)
        return get(meta.paddings, value, defaultPaddingCoords), ""
        
    else
        return get(meta.centers, value, defaultPaddingCoords), ""
    end
end