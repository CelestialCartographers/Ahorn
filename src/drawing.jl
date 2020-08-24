include("extract_sprites_meta.jl")

const atlases = Dict{String, Dict{String, SpriteHolder}}()

const defaultBlankColor = (0.0, 0.0, 0.0, 0.0)
const defaultBlackColor = (0.0, 0.0, 0.0, 1.0)
const defaultWhiteColor = (1.0, 1.0, 1.0, 1.0)

# For missing resources
# Provides a simple image indicating the resource is missing
const fileNotFoundSurface = Assets.missingImage
const fileNotFoundWidth = width(fileNotFoundSurface)
const fileNotFoundHeight = height(fileNotFoundSurface)
const fileNotFoundSpriteHolder = SpriteHolder(
    Sprite(
        0,
        0,

        fileNotFoundWidth,
        fileNotFoundHeight,

        0,
        0,
        fileNotFoundWidth,
        fileNotFoundHeight,

        fileNotFoundSurface,
        ""
    ),

    time(),
    ""
)

function getResourceFromZip(filename::String, resource::String, atlas::String, allowRetry=true)
    if !hasExt(filename, ".zip")
        return nothing
    end

    fileCache = get(resourceZipCache, filename, nothing)

    if fileCache !== nothing
        return get(fileCache, "$atlas/$resource", nothing)

    else
        if allowRetry
            cacheZipContent(filename)

            return getResourceFromZip(filename, resource, atlas, false)

        else
            return nothing
        end
    end
end

const metaYamlResourceNotFound = Dict{String, Any}()

function getSpriteSurface(resource::String, filename::String, atlas="Gameplay")
    # If we have a filename use that, otherwise look for the resource
    filename = isempty(filename) ? something(findExternalSprite(resource), "") : filename

    if hasExt(filename, ".png")
        return open(Cairo.read_from_png, filename), filename

    elseif hasExt(filename, ".zip")
        surface = getResourceFromZip(filename, resource * ".png", atlas)

        return something(surface, fileNotFoundSurface), filename
    end

    return fileNotFoundSurface, filename
end

# Getting sprite meta from zip is slow with this method
function getSpriteMeta(resource::String, filename::String, atlas="Gameplay")
    if !get(config, "load_image_meta_yaml", false)
        return false, false
    end

    # If we have a filename use that, otherwise look for the resource
    filename = isempty(filename) ? something(findExternalSprite(resource), "") : filename
    yamlFilename = splitext(filename)[1] * ".meta.yaml"

    if hasExt(filename, ".png")
        if isfile(yamlFilename)
            try
                return true, open(YAML.load, yamlFilename)

            catch
                return false, "Invalid YAML data"
            end

        else
            return false, false
        end

    elseif hasExt(filename, ".zip")
        data = getResourceFromZip(filename, resource * ".meta.yaml", atlas)

        return data !== nothing, something(data, metaYamlResourceNotFound)
    end

    return fileNotFoundSurface, filename
end

function addSprite!(resource::String, filename::String=""; atlas="Gameplay", force=false)::Sprite
    spriteAtlas = getAtlas(atlas)
    spriteHolder = get(spriteAtlas, resource, nothing)

    if force || spriteHolder === nothing || spriteHolder.sprite.surface === fileNotFoundSurface || spriteHolder.sprite.width == 0 || spriteHolder.sprite.height == 0 || mtime(spriteHolder.path) > spriteHolder.readtime || mtime(spriteHolder.path) == 0
        surface, filename = getSpriteSurface(resource, filename)
        success, meta = getSpriteMeta(resource, filename, atlas)
        hasMeta = isa(meta, Dict)

        if !success && isa(meta, String)
            println(Base.stderr, "Problem with YAML file for resource '$resource', at file '$filename' - '$meta'")
        end

        imWidth = Int(width(surface))
        imHeight = Int(height(surface))

        realWidth = hasMeta ? get(meta, "Width", imWidth) : imWidth
        realHeight = hasMeta ? get(meta, "Height", imHeight) : imHeight

        offsetX = hasMeta ? -get(meta, "X", 0) : 0
        offsetY = hasMeta ? -get(meta, "Y", 0) : 0

        spriteAtlas[resource] = SpriteHolder(
            Sprite(
                0,
                0,

                imWidth,
                imHeight,

                offsetX,
                offsetY,
                realWidth,
                realHeight,

                surface,
                filename
            ),

            time(),
            filename
        )
    end

    return spriteAtlas[resource].sprite
end

function getAtlas(atlas="Gameplay")::Dict{String, SpriteHolder}
    return get!(Dict{String, SpriteHolder}, atlases, atlas)
end

function getAtlasResourceNames(atlas="Gameplay")
    atlas = getAtlas(atlas)

    return collect(keys(atlas))
end

# Get a resource if loaded, otherwise returns the "missing image" sprite
function getSprite(resource::String, atlas="Gameplay")::Sprite
    spriteAtlas = getAtlas(atlas)
    spriteHolder::SpriteHolder = get(spriteAtlas, resource, fileNotFoundSpriteHolder)

    return spriteHolder.sprite
end

function loadAllExternalSprites!(force=false)
    externalSprites = findAllExternalSprites()

    for (texture, raw, atlas) in externalSprites
        addSprite!(fixTexturePath(texture), raw, atlas=atlas, force=force)
    end
end

# Always forced loads, we know they have changed
function loadChangedExternalSprites!()
    externalSprites = findChangedExternalSprites()
    unloadedZips = Set{String}()

    for (texture, raw, atlas) in externalSprites
        if !(raw in unloadedZips) && hasExt(raw, ".zip")
            uncacheZipContent(raw)
            push!(unloadedZips, raw)
        end

        addSprite!(fixTexturePath(texture), raw, atlas=atlas, force=true)
    end
end

const fixedTexturePathsCache = Dict{String, String}()

# Remove .png and convert to unix paths
function fixTexturePath(texture::String)::String
    return get!(fixedTexturePathsCache, texture) do
        replace(last(texture, 4) == ".png" ? texture[1:end - 4] : texture, '\\' => '/')
    end
end

function getTextureSprite(texture::String, atlas="Gameplay")::Sprite
    return getSprite(fixTexturePath(texture), atlas)
end

mutable struct DrawingAlpha
    alpha::Float64
end

const drawingAlpha = DrawingAlpha(1.0)

function setGlobalAlpha!(alpha=1.0)
    drawingAlpha.alpha = alpha
end

getGlobalAlpha() = drawingAlpha.alpha

# This is probably one of the stupid ways to do it.
# Look into this if it turns out being slow

# Image based #

function drawImage(ctx::Cairo.CairoContext, surface::Cairo.CairoSurface, x, y, quadX, quadY, width, height; alpha=nothing, tint=nothing)
    if ctx.ptr != C_NULL
        if tint !== nothing
            tinted = CairoImageSurface(zeros(UInt32, height, width), Cairo.FORMAT_ARGB32)
            tintedCtx = getSurfaceContext(tinted)

            # Don't pass tint or alpha
            drawImage(tintedCtx, surface, 0, 0, quadX, quadY, width, height)
            tintSurfaceMultiplicative!(tinted, tint)

            drawImage(ctx, tinted, x, y, 0, 0, width, height, alpha=alpha)

            deleteSurface(tinted)

        else
            drawingAlpha = something(alpha, getGlobalAlpha())

            Cairo.save(ctx)

            rectangle(ctx, x, y, width, height)
            clip(ctx)

            set_source_surface(ctx, surface, x - quadX, y - quadY)
            pattern_set_filter(get_source(ctx), Cairo.FILTER_NEAREST)

            paint_with_alpha(ctx, drawingAlpha)

            restore(ctx)
        end
    end
end

function drawImage(ctx::Cairo.CairoContext, surface::Cairo.CairoSurface, x, y; alpha=nothing, tint=nothing)
    drawImage(ctx, surface, x, y, 0, 0, round(Int, Cairo.width(surface))::Int, round(Int, Cairo.height(surface))::Int; alpha=alpha, tint=tint)
end

function drawImage(canvas::Gtk.GtkCanvas, name::String, x, y, quadX, quadY, width, height; alpha=nothing, tint=nothing, atlas="Gameplay")
    drawImage(canvas, getSprite(name, atlas), x, y, quadX, quadY, width, height, alpha=alpha, tint=tint)
end

function drawImage(ctx::Cairo.CairoContext, name::String, x, y, quadX, quadY, width, height; alpha=nothing, tint=nothing, atlas="Gameplay")
    drawImage(ctx, getSprite(name, atlas), x, y, quadX, quadY, width, height, alpha=alpha, tint=tint)
end

function drawImage(canvas::Gtk.GtkCanvas, sprite::Sprite, x, y, quadX, quadY, width, height; alpha=nothing, tint=nothing)
    drawImage(Gtk.getgc(canvas), sprite.surface, x, y, quadX, quadY, width, height, alpha=alpha, tint=tint)
end

function drawImage(ctx::Cairo.CairoContext, sprite::Sprite, x, y, quadX=0, quadY=0, width=sprite.width, height=sprite.height; alpha=nothing, tint=nothing, guaranteedNoClip=false)
    if ctx.ptr != C_NULL
        if tint !== nothing
            tinted = CairoImageSurface(zeros(UInt32, height, width), Cairo.FORMAT_ARGB32)
            tintedCtx = getSurfaceContext(tinted)

            # Don't pass tint or alpha
            drawImage(tintedCtx, sprite, 0, 0, quadX, quadY, width, height)
            tintSurfaceMultiplicative!(tinted, tint)

            drawImage(ctx, tinted, x, y, 0, 0, width, height, alpha=alpha)

            deleteSurface(tinted)

        else
            drawingAlpha = something(alpha, getGlobalAlpha())

            needsClip = !guaranteedNoClip && (quadX != 0 || quadY != 0 || width != round(Int, Cairo.width(sprite.surface))::Int || height != round(Int, Cairo.height(sprite.surface))::Int)

            if needsClip
                Cairo.save(ctx)

                rectangle(ctx, x, y, width, height)
                clip(ctx)
            end

            set_source_surface(ctx, sprite.surface, x - quadX - sprite.x, y - quadY - sprite.y)
            pattern_set_filter(get_source(ctx), Cairo.FILTER_NEAREST)

            paint_with_alpha(ctx, drawingAlpha)

            if needsClip
                restore(ctx)
            end
        end
    end
end

function drawImage(canvas::Gtk.GtkCanvas, name::String, x, y; alpha=nothing, tint=nothing, atlas="Gameplay")
    drawImage(canvas, getSprite(name, atlas), x, y, alpha=alpha, tint=tint)
end

function drawImage(ctx::Cairo.CairoContext, name::String, x, y; alpha=nothing, tint=nothing, atlas="Gameplay")
    drawImage(ctx, getSprite(name, atlas), x, y, alpha=alpha, tint=tint)
end

function drawImage(canvas::Gtk.GtkCanvas, sprite::Sprite, x, y; alpha=nothing, tint=nothing)
    drawImage(Gtk.getgc(canvas), sprite, x, y, alpha=alpha, tint=tint)
end

# TODO - Only scale 1/-1 works as intended
function drawSprite(ctx::Cairo.CairoContext, texture::String, x, y; jx=0.5, jy=0.5, sx=1, sy=1, rot=0, alpha=nothing, tint=nothing, atlas="Gameplay")
    if ctx.ptr != C_NULL
        sprite = getTextureSprite(texture, atlas)

        width, height = sprite.realWidth, sprite.realHeight
        drawX, drawY = floor(Int, x - width * jx - sprite.offsetX) , floor(Int, y - height * jy - sprite.offsetY)

        Cairo.save(ctx)

        scale(ctx, sx, sy)
        translate(ctx, sx > 0 ? 0 : -2 * x, sy > 0 ? 0 : -2 * y)
        translate(ctx, drawX, drawY)
        rotate(ctx, rot)
        drawImage(ctx, sprite, 0, 0, alpha=alpha, tint=tint)

        restore(ctx)
    end
end

# Create image from matrix
# Bitmap colors are 0 index based (false = 0, true = 1)
function matrixToSurface(bitmap::Array{T, 2}, colors::Array{rgbaTupleType, 1}=rgbaTupleType[defaultBlackColor, defaultWhiteColor]) where T <: Integer
    height, width = size(bitmap)
    pixels = width * height

    data = Array{Cairo.ARGB32, 1}(undef, pixels)

    ptr = 1
    for x in 1:width, y in 1:height
        color = colors[bitmap[y, x] + 1]
        data[ptr] = Cairo.ARGB32(color[1], color[2], color[3], color[4])

        ptr += 1
    end

    data = permutedims(reshape(data, (height, width)))

    return CairoImageSurface(data)
end

# Image tinting, super inefficient

function tintSurfaceAdditive(surface::Cairo.CairoSurface, color::rgbaTupleType, width=width(surface), height=height(surface))
    for x in 1:floor(Int, width), y in 1:floor(Int, height)
        pixelColor = argb32ToRGBATuple(surface.data[x, y]) ./ 255
        surface.data[x, y] = normRGBA32Tuple2ARGB32(min.(1.0, pixelColor .+ color))
    end

    return surface
end

function tintSurfaceMultiplicative!(surface::Cairo.CairoSurface, color::rgbaTupleType, width=width(surface), height=height(surface))
    for x in 1:floor(Int, width), y in 1:floor(Int, height)
        pixelColor = argb32ToRGBATuple(surface.data[x, y]) ./ 255
        surface.data[x, y] = normRGBA32Tuple2ARGB32(pixelColor .* color)
    end
end

# Shapes #

function setSourceColor(ctx, c::rgbTupleType)
    set_source_rgb(ctx, c[1], c[2], c[3])
end

function setSourceColor(ctx, c::rgbaTupleType)
    set_source_rgba(ctx, c[1], c[2], c[3], c[4])
end

function paintSurface(ctx::Cairo.CairoContext, c=defaultWhiteColor)
    if ctx.ptr != C_NULL
        setSourceColor(ctx, c)
        paint(ctx)
    end
end

paintSurface(surface::Cairo.CairoSurface, c=defaultWhiteColor) = paintSurface(getSurfaceContext(surface), c)

function clearArea(ctx::Cairo.CairoContext, x, y, width, height)
    if ctx.ptr != C_NULL
        Cairo.save(ctx)

        set_operator(ctx, Cairo.OPERATOR_CLEAR)
        rectangle(ctx, x, y, width, height)
        fill(ctx)

        restore(ctx)
    end
end

clearArea(surface::Cairo.CairoSurface, x, y, width, height) = clearArea(getSurfaceContext(surface), x, y, width, height)

function clearSurface(ctx::Cairo.CairoContext)
    return clearArea(ctx, 0, 0, width(ctx), height(ctx))
end

clearSurface(surface::Cairo.CairoSurface) = clearSurface(getSurfaceContext(surface))

# With border
function drawRectangle(ctx::Cairo.CairoContext, x, y, w, h, fc=defaultBlackColor, rc=defaultBlankColor)
    if ctx.ptr != C_NULL
        Cairo.save(ctx)

        setSourceColor(ctx, fc)
        rectangle(ctx, x, y, w, h)
        fill_preserve(ctx)
        setSourceColor(ctx, rc)
        stroke(ctx)

        restore(ctx)
    end
end

function drawRectangle(ctx::Cairo.CairoContext, rect::Rectangle, fc=defaultBlackColor, rc=defaultBlankColor)
    return drawRectangle(ctx, rect.x, rect.y, rect.w, rect.h, fc, rc)
end

function drawLines(ctx::Cairo.CairoContext, nodes, sc=defaultBlackColor; thickness=2, filled=false, fc=sc)
    if ctx.ptr != C_NULL
        if length(nodes) < 2
            return
        end

        Cairo.save(ctx)

        set_antialias(ctx, thickness)
        set_line_width(ctx, thickness)

        move_to(ctx, nodes[1][1], nodes[1][2])

        for node in nodes[2:end]
            line_to(ctx, node[1], node[2])
        end
        
        if filled
            setSourceColor(ctx, fc)
            fill_preserve(ctx)
        end

        setSourceColor(ctx, sc)
        stroke(ctx)
        restore(ctx)
    end
end

function drawSimpleCurve(ctx::Cairo.CairoContext, curve::SimpleCurve, c=defaultBlackColor; resolution=25, thickness=2)
    points = [getPoint(curve, i / resolution) for i in 0:resolution]

    drawLines(ctx, points, c, thickness=thickness)
end

function drawArc(ctx::Cairo.CairoContext, x, y, r, alpha, beta, c=defaultBlackColor)
    if ctx.ptr != C_NULL
        Cairo.save(ctx)

        setSourceColor(ctx, c)
        arc(ctx, x, y, r, alpha, beta)
        stroke(ctx)

        restore(ctx)
    end
end

function drawCircle(ctx::Cairo.CairoContext, x, y, r, c=defaultBlackColor)
    drawArc(ctx, x, y, r, 0, 2 * pi, c)
end

function drawArrow(ctx::Cairo.CairoContext, x1, y1, x2, y2, c=defaultBlackColor; filled=true, headLength=15, headTheta=pi / 6)
    theta = atan(y2 - y1, x2 - x1)
    len = sqrt((x1 - x2)^2 + (y1 - y2)^2)

    shaftLen = len - headLength
    sideLen = tan(headTheta) * headLength

    shaftX = shaftLen * cos(theta) + x1
    shaftY = shaftLen * sin(theta) + y1

    dx = sideLen * cos(theta + pi / 2)
    dy = sideLen * sin(theta + pi / 2)

    nodes = Tuple{Float64, Float64}[
        (x1, y1),
        (shaftX, shaftY),
        (shaftX + dx, shaftY + dy),
        (x2, y2),
        (shaftX - dx, shaftY - dy),
        (shaftX, shaftY),
    ]

    return drawLines(ctx, nodes, c, filled=filled)
end