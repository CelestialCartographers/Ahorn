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

struct Mask
    tiles::UInt8
    ignores::UInt8
end

# Relevant characters of the tile mask string
# We never need to check the centre tile, otherwise we wouldn't be in the mask check
const lookupmask = [1, 2, 3, 5, 7, 9, 10, 11]

# Convert mask string into a bitmask.
# ignoremask is 1 for every tile that should NOT be ignored.
function getMaskFromString(s::String)
    data = s[lookupmask]
    tilemask = UInt8(0)
    ignoremask = UInt8(0)
    for (i, c) in enumerate(data)
        tilemask |= UInt8(c == '1') << (8 - i)
        ignoremask |= UInt8(c != 'x') << (8 - i)
    end
    return Mask(tilemask, ignoremask)
end

function sortScore(mask::Mask)
    # Counts the number of 0-bits in the ignore string
    # by counting the number of 1-bits.
    return 8 - sum([(mask.ignores >> i) & 0b1 for i = 0:7])
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

struct Ignore
    wildcard::Bool
    ignores::String

    Ignore(s::String) = new('*' in s, filter(c -> c != '*', s))
end

function loadTilesetXML(fn::String)
    xdoc = parse_file(fn)
    xroot = root(xdoc)

    paths = Dict{Char, String}()
    masks = Dict{Char, Array{MaskData, 1}}()
    padding = Dict{Char, Array{Coord, 1}}()
    center = Dict{Char, Array{Coord, 1}}()
    ignores = Dict{Char, Ignore}()

    orderedElements = sort(collect(child_elements(xroot)), by=set -> attribute(set, "copy") !== nothing)

    for set in orderedElements
        id = attribute(set, "id")[1] # Char doesn't work on 1 length string?
        path = attribute(set, "path")
        copyTileset = attribute(set, "copy")
        ignore = attribute(set, "ignores")

        paths[id] = "tilesets/$path"

        if ignore !== nothing
            ignores[id] = Ignore(ignore)
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
    ignores::Dict{Char, Ignore}
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

function checkPadding(data::Array{Char, 2}, x::Int, y::Int, width::Int, height::Int)
    # Checks for '0' even though getIfInboundsKnownSize might return ' '
    # This is due to quirks/special flags in the actuall autotiler
    return getIfInboundsKnownSize(data, y - 2, x, height, width, ' ') == '0' ||
        getIfInboundsKnownSize(data, y + 2, x, height, width, ' ') == '0' ||
        getIfInboundsKnownSize(data, y, x - 2, height, width, ' ') == '0' ||
        getIfInboundsKnownSize(data, y, x + 2, height, width, ' ') == '0'
end

const ignoresDefault = Ignore("")

# Return the "mask" value for a tile
# Returns as UInt8 for performance
# Manual string iteratation for performance
function checkTile(value::Char, target::Char, ignore::Ignore=ignoresDefault)
    if target == '0' || (ignore.wildcard && value != target)
        return 0b0

    else
        for c in ignore.ignores
            if target == c
                return 0b0
            end
        end
    end

    return 0b1
end

function checkMask(mask::Mask, adj::UInt8)
    return ((adj ⊻ mask.tiles) & mask.ignores) == 0
end

function getIfInboundsKnownSize(data::Array{Char, 2}, y::Int, x::Int, height::Int, width::Int, default::Char='0')::Char
    if 1 <= y <= height && 1 <= x <= width
        return @inbounds data[y, x]

    else
        return default
    end
end

# Unrolled for performance
function getAdjacencyMask(data::Array{Char, 2}, y::Int, x::Int, height::Int, width::Int, default::Char, ignores::Ignore)::UInt8
    return checkTile(default, getIfInboundsKnownSize(data, y - 1, x - 1, height, width, default), ignores) << 7 |
        checkTile(default, getIfInboundsKnownSize(data, y - 1, x, height, width, default), ignores) << 6 |
        checkTile(default, getIfInboundsKnownSize(data, y - 1, x + 1, height, width, default), ignores) << 5 |

        checkTile(default, getIfInboundsKnownSize(data, y, x - 1, height, width, default), ignores) << 4 |
        checkTile(default, getIfInboundsKnownSize(data, y, x + 1, height, width, default), ignores) << 3 |

        checkTile(default, getIfInboundsKnownSize(data, y + 1, x - 1, height, width, default), ignores) << 2 |
        checkTile(default, getIfInboundsKnownSize(data, y + 1, x, height, width, default), ignores) << 1 |
        checkTile(default, getIfInboundsKnownSize(data, y + 1, x + 1, height, width, default), ignores)
end

const defaultPaddingCoords = Coord[Coord(0, 0)]
const maskDataDefault = MaskData[]

function getMaskQuads(x::Int, y::Int, tiles::Tiles, meta::TilerMeta)
    data = tiles.data
    height, width = size(data)
    value = @inbounds tiles.data[y, x]

    masks = get(meta.masks, value, maskDataDefault)
    ignores = get(meta.ignores, value, ignoresDefault)

    adjacent = getAdjacencyMask(data, y, x, height, width, value, ignores)

    for data in masks
        if checkMask(data.mask, adjacent)
            return data.coords, data.sprites
        end
    end

    if checkPadding(tiles.data, x, y, width, height)
        return get(meta.paddings, value, defaultPaddingCoords), ""
        
    else
        return get(meta.centers, value, defaultPaddingCoords), ""
    end
end