#using Images
#using Colors

struct Img
    path::String
    width::Int32
    height::Int32
    texture::Array{Cairo.ARGB32,1}
end

ARGB(r, g, b, a) = reinterpret(Cairo.ARGB32, UInt32(a)<<24 | UInt32(b)<<16 | UInt32(g)<<8 | UInt32(r))

function extractFromFile(path::String, filename::String)
    fh = open(joinpath(path, filename), "r")
    data = IOBuffer(read(fh))
    close(fh)
    width = read(data, Int32)
    height = read(data, Int32)
    hasAlpha = read(data, UInt8) == 1
    totalSize = width * height
    textureData = Array{Cairo.ARGB32,1}(totalSize)
    j = 1
    while j < totalSize
        repeat = read(data, UInt8)
        if hasAlpha
            alpha = read(data, UInt8)
            if alpha > 0
                textureData[j] = ARGB(read(data, UInt8), read(data, UInt8), read(data, UInt8), alpha)
            else
                textureData[j] = ARGB(UInt8(0), UInt8(0), UInt8(0), UInt8(0))
            end
        else
            textureData[j] = ARGB(read(data, UInt8), read(data, UInt8), read(data, UInt8), UInt8(0xFF))
        end
        if repeat > 1
            for i in 1:repeat - 1
                textureData[j + i] = deepcopy(textureData[j])
            end
        end
        j += repeat
    end
    Img(splitext(filename)[1], width, height, textureData)
end

function extractGraphics(celestedir::String)
    path = joinpath(celestedir, "Content", "Graphics", "Atlases")
    filepaths = String[]
    for (root, dirs, files) in walkdir(path), file in filter(f -> contains(f, ".data"), files)
        push!(filepaths, relpath(joinpath(root, file), path))
    end
    println("Extracting from $path - $(length(filepaths)) files")
    images = Img[]
    for file in filepaths
        println(file)
        push!(images, extractFromFile(path, file))
    end
    return images
end

function dumpSprites(source::String, destination::String=source)
    img = extractFromFile(source, "Gameplay0.data")

    surface = CairoImageSurface(reshape(img.texture, (img.height, img.width)))
    open(io -> write_to_png(surface, io), joinpath(destination, "Gameplay.png"), "w")
end