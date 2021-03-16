mutable struct Sprite
    x::Int
    y::Int

    width::Int
    height::Int

    offsetX::Int
    offsetY::Int
    realWidth::Int
    realHeight::Int

    surface::Cairo.CairoSurface
    filename::String

    function Sprite(x, y, width, height, offsetX, offsetY, realWidth, realHeight, surface, filename)
        return finalizer(s -> deleteSurface(s.surface), new(x, y, width, height, offsetX, offsetY, realWidth, realHeight, surface, filename))
    end
end

mutable struct SpriteHolder
    sprite::Sprite

    readtime::Float64
    path::String
end

function prepareSurfaceForQuad(atlasSurface::Cairo.CairoSurface, x, y, width, height, offsetX, offsetY, realWidth, realHeight)
    surface = CairoARGBSurface(width, height)
    ctx = getSurfaceContext(surface)

    drawImage(ctx, atlasSurface, 0, 0, x, y, width, height)

    return surface
end

function loadSprites(metaFn::String, spritesFn::String)
    splitAtlas = get(config, "split_atlas_into_smaller_surfaces", true)

    surface = open(Cairo.read_from_png, spritesFn)
    buffer = IOBuffer(open(read, metaFn))

    res = Dict{String, SpriteHolder}()

    # Mostly useless information
    read(buffer, Int32)
    Maple.readString(buffer)
    read(buffer, Int32)

    count = read(buffer, Int16)
    for i in 1:count
        dataFile = Maple.readString(buffer)
        sprites = read(buffer, Int16)

        for j in 1:sprites
            path = replace(Maple.readString(buffer), "\\" => "/")

            x = read(buffer, Int16)
            y = read(buffer, Int16)

            width = read(buffer, Int16)
            height = read(buffer, Int16)

            offsetX = read(buffer, Int16)
            offsetY = read(buffer, Int16)
            realWidth = read(buffer, Int16)
            realHeight = read(buffer, Int16)

            quadSurface = splitAtlas ? prepareSurfaceForQuad(surface, x, y, width, height, offsetX, offsetY, realWidth, realHeight) : surface

            sprite = Sprite(
                splitAtlas ? 0 : x,
                splitAtlas ? 0 : y,

                width,
                height,

                offsetX,
                offsetY,

                realWidth,
                realHeight,

                quadSurface,
                spritesFn
            )

            res[path] = SpriteHolder(
                sprite,

                time(),
                spritesFn
            )
        end
    end

    if splitAtlas
        deleteSurface(surface)
    end

    return res
end

function findTextureAnimations(texture::String, sprites::Dict{String, SpriteHolder}; maxPadding=7)::Array{String, 1}
    textures = String[]

    for i in 1:maxPadding
        testFrame = texture * "0"^i

        if haskey(sprites, testFrame) && sprites[testFrame].sprite.width != 0 && sprites[testFrame].sprite.height != 0
            for j in 0:10^i - 1
                frame = texture * lpad(j, i, "0")

                if haskey(sprites, frame) && sprites[frame].sprite.width != 0 && sprites[frame].sprite.height != 0
                    push!(textures, frame)

                else
                    break
                end
            end
        end
    end

    return textures
end