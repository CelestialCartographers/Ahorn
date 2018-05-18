using LightXML

struct Mask
    mask::Array{Int, 2}
end

# Convert mask string into a 3x3 matrix
function Mask(s::String)
    data = replace(replace(s, "-", ""), "x", "2")

    return Mask(transpose(reshape(parse.(Int, (collect(data))), (3, 3))))
end

function sortScore(m::Mask)
    return length(filter(v -> v == 2, m.mask))
end

# Get quads for a given mask
function convertTileString(s::String)
    parts = split(s, ";")
    res = Tuple{Integer, Integer}[]

    for part in parts
        x, y = parse.(Int, split(part, ","))

        push!(res, (x, y))
    end

    return res
end

function loadTilesetXML(fn::String)
    xdoc = parse_file(fn)
    xroot = root(xdoc)

    paths = Dict{Char, String}()
    masks = Dict{Char, Any}()
    padding = Dict{Char, Array{Tuple{Integer, Integer}, 1}}()
    center = Dict{Char, Array{Tuple{Integer, Integer}, 1}}()
    ignores = Dict{Char, Array{Char, 1}}()

    for set in child_elements(xroot)
        id = attribute(set, "id")[1] # Char doesn't work on 1 length string?
        path = attribute(set, "path")
        copyTileset = attribute(set, "copy")
        ignore = attribute(set, "ignores")

        paths[id] = "tilesets/$path"

        if ignore != nothing
            ignores[id] = collect(ignore)
        end

        if copyTileset != nothing
            padding[id] = padding[copyTileset[1]]
            center[id] = center[copyTileset[1]]
            masks[id] = masks[copyTileset[1]]

            continue
        end

        currMasks = Tuple{Mask, Array{Tuple{Integer, Integer}, 1}}[]

        for c in child_elements(set)
            mask = attribute(c, "mask")
            tilesString = attribute(c, "tiles")

            if mask == "padding"
                padding[id] = convertTileString(tilesString)

            elseif mask == "center"
                center[id] = convertTileString(tilesString)

            else
                push!(currMasks, (Mask(mask), convertTileString(tilesString)))
            end
        end

        masks[id] = currMasks
        sort!(masks[id], by=m -> sortScore(m[1]), rev=false)
    end


    return paths, masks, padding, center, ignores
end

struct TilerMeta
    paths::Dict{Char, String}
    masks::Dict{Char, Any}
    paddings::Dict{Char, Array{Tuple{Integer, Integer}, 1}}
    centers::Dict{Char, Array{Tuple{Integer, Integer}, 1}}
    ignores::Dict{Char, Array{Char, 1}}
end

TilerMeta(s::String) = TilerMeta(loadTilesetXML(s)...)

fgTilerMeta = TilerMeta(joinpath(storageDirectory, "ForegroundTiles.xml"))
bgTilerMeta = TilerMeta(joinpath(storageDirectory, "BackgroundTiles.xml"))

function getTile(tiles::Tiles, x::Integer, y::Integer)
    return get(tiles.data, (y, x), ' ')
end

function checkPadding(tiles::Tiles, x::Integer, y::Integer)
    # Checks for '0' even though getTile might return ' '
    # This is due to quirks/special flags in the actuall autotiler
    return getTile(tiles, x - 2, y) == '0' || getTile(tiles, x + 2, y) == '0' || getTile(tiles, x, y - 2) == '0' || getTile(tiles, x, y + 2) == '0'
end

# Return the "mask" value for a tile
function checkTile(value::Char, target::Char, ignore::Array{Char, 1}=Char[])
    return !(target == '0' || target in ignore || ('*' in ignore && value != target))
end

function checkMask(adj::Array{Bool, 2}, mask::Mask)
    mask = mask.mask
    for i in 1:9
        if mask[i] != 2
            if adj[i] != mask[i]
                return false
            end
        end
    end

    return true
end

function getMaskQuads(x::Integer, y::Integer, tiles::Tiles, meta::TilerMeta)
    value = tiles.data[y, x]

    masks = get(meta.masks, value, Tuple{Mask, Array{Tuple{Integer, Integer}, 1}}[])
    ignore = get(meta.ignores, value, Char[])

    adjacent = get(tiles.data, (y - 1:y + 1, x - 1:x + 1), value)
    adjacent = [checkTile(value, target, ignore) for target in adjacent]

    for data in masks
        mask, quads = data
        
        if checkMask(adjacent, mask)
            return quads
        end
    end

    if checkPadding(tiles, x, y)
        return get(meta.paddings, value, Tuple{Integer, Integer}[(0, 0)])
        
    else
        return get(meta.centers, value, Tuple{Integer, Integer}[(0, 0)])
    end
    
    return (5, 12)
end