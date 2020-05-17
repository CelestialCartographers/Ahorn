struct Sprite
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
end

mutable struct SpriteHolder
    sprite::Sprite

    readtime::Float64
    path::String
end

function loadSprites(metaFn::String, spritesFn::String)
    surface = open(Cairo.read_from_png, spritesFn)
    fh = open(metaFn)

    res = Dict{String, SpriteHolder}()

    # Mostly useless information
    read(fh, Int32)
    Maple.readString(fh)
    read(fh, Int32)

    count = read(fh, Int16)
    for i in 1:count
        dataFile = Maple.readString(fh)
        sprites = read(fh, Int16)

        for j in 1:sprites
            path = replace(Maple.readString(fh), "\\" => "/")

            sprite = Sprite(
                read(fh, Int16),
                read(fh, Int16),

                read(fh, Int16),
                read(fh, Int16),

                read(fh, Int16),
                read(fh, Int16),
                read(fh, Int16),
                read(fh, Int16),

                surface,
                spritesFn
            )

            res[path] = SpriteHolder(
                sprite,

                time(),
                spritesFn
            )
        end
    end

    close(fh)

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