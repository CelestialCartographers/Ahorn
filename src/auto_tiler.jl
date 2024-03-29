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
        rawX, rawY = split(part, ",")
        x, y = parse(Int, rawX), parse(Int, rawY)

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
    sprites::Array{String, 1}
end

struct Ignore
    wildcard::Bool
    ignores::String

    Ignore(s::String) = new('*' in s, filter(c -> c != '*', s))
end

getTilesetId(id::String) = getTilesetId(id[1])
getTilesetId(id::Char) = id

function loadTilesetXML(fn::String)
    if !isfile(fn)
        error("File '$fn' not found")
    end

    xdoc = parse_file(fn)
    xroot = root(xdoc)

    paths = Dict{Char, String}()
    masks = Dict{Char, Array{MaskData, 1}}()
    padding = Dict{Char, Array{Coord, 1}}()
    center = Dict{Char, Array{Coord, 1}}()
    ignores = Dict{Char, Ignore}()

    orderedElements = sort(collect(child_elements(xroot)), by=set -> attribute(set, "copy") !== nothing)

    for set in orderedElements
        rawId = attribute(set, "id")
        id = getTilesetId(rawId)
        path = attribute(set, "path")
        copyTileset = attribute(set, "copy")
        ignore = attribute(set, "ignores")

        if id === nothing
            error("Tileset ID must be ASCII character, got '$rawId'")
        end

        if haskey(paths, id)
            error("Tileset ID '$id' is already in use")
        end

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
                spritesRaw = attribute(c, "sprites")
                sprites = isa(spritesRaw, String) ? split(spritesRaw, ",") : String[]

                push!(currMasks, MaskData(
                    getMaskFromString(mask),
                    quads,
                    sprites
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

# Filename => (result, load time)
const loadedXMLCache = Dict{String, Tuple{Any, Number}}()

function displayCustomXMLWarning(title::String, message::String)
    topMostInfoDialog("$title\n$message")
end

function displayCustomXMLWarning(title::String, exception::Exception)
    message = sprint(showerror, exception)

    displayCustomXMLWarning(title, message)
end

function getCustomTilesXMLPath(side::Side, filename::String, key::String)
    meta = get(Dict{String, Any}, side.data, "meta")
    metaPath = get(meta, key, "")

    hasRoot, modRoot = getModRoot(filename)
    xmlPath = joinpath(modRoot, metaPath)

    if !isempty(metaPath) && hasRoot
        return xmlPath
    end
end

getCustomTilesXMLPath(side::Nothing, filename::String, key::String) = nothing

function loadCustomXML(loader::Union{Function, Type}, filename::String, errorTitle::String, force::Bool=false, quiet::Bool=false)
    if !force
        result, modified = get(loadedXMLCache, filename, (nothing, 0))

        if modified >= mtime(filename)
            return result
        end
    end

    try
        result = loader(filename)
        loadedXMLCache[filename] = (result, mtime(filename))

        return result

    catch e
        if !quiet
            displayCustomXMLWarning(errorTitle, e)

            println(Base.stderr, e)

            for (exc, bt) in Base.catch_stack()
                showerror(Base.stderr, exc, bt)
                println(Base.stderr, "")
            end
        end

        loadedXMLCache[filename] = (nothing, mtime(filename))
    end

    return nothing
end

# Good enough to cache and retrieve via the custom XML loader
# We don't need any error message, vanilla assets shouldn't fail
# Never need to force reloads, that is mostly just for error message sake
function loadVanillaXML(loader::Union{Function, Type}, filename::String)
    return loadCustomXML(loader, filename, "", false, true)
end

function loadTilesMeta(side::Union{Side, Nothing}, filename::String, fg::Bool=false, force::Bool=false)
    defaultPath = joinpath(storageDirectory, "XML", fg ? "ForegroundTiles.xml" : "BackgroundTiles.xml")
    customPath = getCustomTilesXMLPath(side, filename, fg ? "ForegroundTiles" : "BackgroundTiles")

    if customPath !== nothing
        xmlType = fg ? "Foreground Tiles" : "Background Tiles"
        errorTitle = "Failed to load custom $xmlType XML"
        customMeta = loadCustomXML(TilerMeta, customPath, errorTitle, force)

        if customMeta !== nothing
            return customMeta
        end
    end

    return loadVanillaXML(TilerMeta, defaultPath)
end

function loadAnimatedTilesMeta(side::Union{Side, Nothing}, filename::String, force::Bool=false)
    defaultPath = joinpath(storageDirectory, "XML",  "AnimatedTiles.xml")
    customPath = getCustomTilesXMLPath(side, filename, "AnimatedTiles")

    if customPath !== nothing
        errorTitle = "Failed to load custom Animated Tiles XML"
        customMeta = loadCustomXML(loadAnimatedTilesXML, customPath, errorTitle, force)

        if customMeta !== nothing
            return customMeta
        end
    end

    return loadVanillaXML(loadAnimatedTilesXML, defaultPath)
end

function loadXMLMeta(force::Bool=true)
    side = loadedState.side
    filename = loadedState.filename

    global fgTilerMeta = loadTilesMeta(side, filename, true, force)
    global bgTilerMeta = loadTilesMeta(side, filename, false, force)
    global animatedTilesMeta = loadAnimatedTilesMeta(side, filename, force)
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

    masks = get(meta.masks, value, maskDataDefault)::Array{MaskData, 1}
    ignores = get(meta.ignores, value, ignoresDefault)::Ignore

    adjacent = getAdjacencyMask(data, y, x, height, width, value, ignores)

    for data in masks
        if checkMask(data.mask, adjacent)
            return data.coords, data.sprites
        end
    end

    if checkPadding(tiles.data, x, y, width, height)
        return get(meta.paddings, value, defaultPaddingCoords), String[]

    else
        return get(meta.centers, value, defaultPaddingCoords), String[]
    end
end