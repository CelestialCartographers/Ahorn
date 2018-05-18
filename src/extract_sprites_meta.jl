struct Sprite
    x::Integer
    y::Integer

    width::Integer
    height::Integer

    offsetX::Integer
    offsetY::Integer
    realWidth::Integer
    realHeight::Integer

    surface::Cairo.CairoSurface
end

function loadSprites(metaFn::String, spritesFn::String)
    surface = read_from_png(spritesFn)
    fh = open(metaFn)

    res = Dict{String, Sprite}()

    # Mostly useless information
    read(fh, Int32)
    Maple.readString(fh)
    read(fh, Int32)

    count = read(fh, Int16)
    for i in 1:count
        dataFile = Maple.readString(fh)
        sprites = read(fh, Int16)

        for j in 1:sprites
            path = replace(Maple.readString(fh), "\\", "/")

            res[path] = Sprite(
                read(fh, Int16),
                read(fh, Int16),

                read(fh, Int16),
                read(fh, Int16),

                read(fh, Int16),
                read(fh, Int16),
                read(fh, Int16),
                read(fh, Int16),

                surface
            )
        end
    end

    close(fh)

    return res
end