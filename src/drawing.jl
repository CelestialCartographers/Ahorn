using YAML

include("extract_sprites_meta.jl")

atlases = Dict{String, Dict{String, SpriteHolder}}()

drawingAlpha = 1
fileNotFoundSurface = Assets.missingImage

spriteSurfaceCache = Dict{String, Tuple{Number, Cairo.CairoSurface, String}}()
spriteYAMLCache = Dict{String, Tuple{Number, Bool, Any}}()

function getSpriteSurface(resource::String, filename::String, atlas::String="Gameplay")
    # If we have a filename use that, otherwise look for the resource
    filename = isempty(filename) ? findExternalSprite(resource) : filename
    filename = isa(filename, String) ? filename : ""

    if isfile(filename)
        # Check if we have a cached version from zipfile
        cacheInfo = get(spriteSurfaceCache, resource, nothing)
        fileModified = mtime(filename)

        if cacheInfo !== nothing && cacheInfo[1] <= fileModified
            return cacheInfo[2], cacheInfo[3]
        end

        if hasExt(filename, ".png")
            surface = open(Cairo.read_from_png, filename)
            spriteSurfaceCache[resource] = (fileModified, surface, filename)

            return surface, filename

        elseif hasExt(filename, ".zip")
            # Cheaper to fix resource name than every filename from zip
            # Always uses Unix path
            resourcePath = "Graphics/Atlases/$atlas/" * splitext(resource)[1] * ".png"
            surface = fileNotFoundSurface

            zipfh = ZipFile.Reader(filename)

            for file in zipfh.files
                if file.name == resourcePath
                    surface = Cairo.read_from_png(file)

                    break
                end
            end
            
            close(zipfh)

            spriteSurfaceCache[resource] = (fileModified, surface, filename)

            return surface, filename
        end

    else
        return fileNotFoundSurface, filename
    end
end

function getSpriteMeta(resource::String, filename::String, atlas::String="Gameplay")
    if !get(config, "load_image_meta_yaml", false)
        return false, false
    end

    # If we have a filename use that, otherwise look for the resource
    filename = isempty(filename) ? findExternalSprite(resource) : filename
    filename = isa(filename, String) ? filename : ""

    if resource !== nothing && isfile(filename)
        cacheInfo = get(spriteYAMLCache, resource, nothing)

        if hasExt(filename, ".png")
            yamlFilename = splitext(filename)[1] * ".meta.yaml"
            fileModified = mtime(yamlFilename)

            if isfile(yamlFilename)
                if cacheInfo !== nothing && cacheInfo[1] <= fileModified && fileModified != 0
                    return cacheInfo[2], cacheInfo[3]
                end
                
                try
                    data = open(YAML.load, yamlFilename)
                    spriteYAMLCache[resource] = (fileModified, true, data)

                    return true, data

                catch
                    spriteYAMLCache[resource] = (fileModified, false, "Invalid YAML data")

                    return false, "Invalid YAML data"
                end
            end

        elseif hasExt(filename, ".zip")
            fileModified = mtime(filename)

            if cacheInfo !== nothing && cacheInfo[1] <= fileModified
                return cacheInfo[2], cacheInfo[3]
            end

            success = true
            res = nothing

            zipfh = ZipFile.Reader(filename)

            # Cheaper to fix resource name than every filename from zip
            # Always uses Unix path
            resourcePath = "Graphics/Atlases/$atlas/" * splitext(resource)[1] * ".meta.yaml"

            for file in zipfh.files
                if file.name == resourcePath
                    try
                        res = YAML.load(String(read(file)))

                    catch
                        res = "Invalid YAML data"
                        success = false
                    end

                    break
                end
            end
            
            close(zipfh)

            spriteYAMLCache[resource] = (fileModified, success, res)

            return success, res
        end
    end
    
    return false, false
end

function addSprite!(resource::String, filename::String=""; atlas::String="Gameplay", force::Bool=false)
    spriteAtlas = getAtlas(atlas)
    spriteHolder = get(spriteAtlas, resource, nothing)

    if spriteHolder === nothing || spriteHolder.sprite.surface === fileNotFoundSurface || spriteHolder.sprite.width == 0 || spriteHolder.sprite.height == 0 || mtime(spriteHolder.path) > spriteHolder.readtime || mtime(spriteHolder.path) == 0 || force
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

function getAtlas(atlas::String="Gameplay")
    if !haskey(atlases, atlas)
        atlases[atlas] = Dict{String, SpriteHolder}()
    end

    return atlases[atlas]
end

function getAtlasResourceNames(atlas::String="Gameplay")
    atlas = getAtlas(atlas)

    return collect(keys(atlas))
end

# Gets a resource or loads a modded one
function getSprite(name::String, atlas::String="Gameplay"; force::Bool=false)
    return addSprite!(name, atlas=atlas, force=force)
end

function loadExternalSprites!(force::Bool=false)
    externalSprites = findExternalSprites()
    for (texture, raw, atlas) in externalSprites
        addSprite!(fixTexturePath(texture), raw, atlas=atlas, force=force)
    end
end

# remove .png and convert to unix paths
function fixTexturePath(texture::String)
    return replace(Base.splitext(texture)[1], "\\" => "/")
end

function getTextureSprite(texture::String, atlas::String="Gameplay")
    return getSprite(fixTexturePath(texture), atlas)
end

function setGlobalAlpha!(alpha::Number=1)
    global drawingAlpha = alpha
end

getGlobalAlpha() = drawingAlpha

# This is probably one of the stupid ways to do it.
# Look into this if it turns out being slow

# Image based #

function drawImage(ctx::Cairo.CairoContext, surface::Cairo.CairoSurface, x::Number, y::Number, quadX::Number, quadY::Number, width::Number, height::Number; alpha::Number=getGlobalAlpha(), tint::Union{Nothing, rgbaTupleType}=nothing)
    if tint !== nothing
        tinted = CairoImageSurface(zeros(UInt32, height, width), Cairo.FORMAT_ARGB32)
        tintedCtx = CairoContext(tinted)

        # Don't pass tint or alpha
        drawImage(tintedCtx, surface, 0, 0, quadX, quadY, width, height)
        tinted = tintSurfaceMultiplicative(tinted, tint)

        drawImage(ctx, tinted, x, y, 0, 0, width, height, alpha=alpha)

    else
        Cairo.save(ctx)

        rectangle(ctx, x, y, width, height)
        clip(ctx)
    
        set_source_surface(ctx, surface, x - quadX, y - quadY)
        pattern_set_filter(get_source(ctx), Cairo.FILTER_NEAREST)
    
        paint_with_alpha(ctx, alpha)
    
        restore(ctx)
    end
end

function drawImage(ctx::Cairo.CairoContext, surface::Cairo.CairoSurface, x::Number, y::Number; alpha::Number=getGlobalAlpha(), tint::Union{Nothing, rgbaTupleType}=nothing)
    drawImage(ctx, surface, x, y, 0, 0, Int(surface.width), Int(surface.height); alpha=alpha, tint=tint)
end

drawImage(canvas::Gtk.GtkCanvas, name::String, x::Number, y::Number, quadX::Number, quadY::Number, width::Number, height::Number; alpha::Number=getGlobalAlpha(), tint::Union{Nothing, rgbaTupleType}=nothing, atlas::String="Gameplay") = drawImage(canvas, getSprite(name, atlas), x, y, quadX, quadY, width, height, alpha=alpha, tint=tint)
drawImage(ctx::Cairo.CairoContext, name::String, x::Number, y::Number, quadX::Number, quadY::Number, width::Number, height::Number; alpha::Number=getGlobalAlpha(), tint::Union{Nothing, rgbaTupleType}=nothing, atlas::String="Gameplay") = drawImage(ctx, getSprite(name, atlas), x, y, quadX, quadY, width, height, alpha=alpha, tint=tint)
drawImage(canvas::Gtk.GtkCanvas, sprite::Sprite, x::Number, y::Number, quadX::Number, quadY::Number, width::Number, height::Number; alpha::Number=getGlobalAlpha(), tint::Union{Nothing, rgbaTupleType}=nothing) = drawImage(Gtk.getgc(canvas), sprite.surface, x, y, quadX, quadY, width, height, alpha=alpha, tint=tint)

function drawImage(ctx::Cairo.CairoContext, sprite::Sprite, x::Number, y::Number, quadX::Number, quadY::Number, width::Number, height::Number; alpha::Number=getGlobalAlpha(), tint::Union{Nothing, rgbaTupleType}=nothing)
    if tint !== nothing
        tinted = CairoImageSurface(zeros(UInt32, height, width), Cairo.FORMAT_ARGB32)
        tintedCtx = CairoContext(tinted)

        # Don't pass tint or alpha
        drawImage(tintedCtx, sprite, 0, 0, quadX, quadY, width, height)
        tinted = tintSurfaceMultiplicative(tinted, tint)

        drawImage(ctx, tinted, x, y, 0, 0, width, height, alpha=alpha)

    else
        Cairo.save(ctx)

        rectangle(ctx, x, y, width, height)
        clip(ctx)
    
        set_source_surface(ctx, sprite.surface, x - quadX - sprite.x, y - quadY - sprite.y)
        pattern_set_filter(get_source(ctx), Cairo.FILTER_NEAREST)
    
        paint_with_alpha(ctx, alpha)
    
        restore(ctx)
    end
end

drawImage(canvas::Gtk.GtkCanvas, name::String, x::Number, y::Number; alpha::Number=getGlobalAlpha(), tint::Union{Nothing, rgbaTupleType}=nothing, atlas::String="Gameplay") = drawImage(canvas, getSprite(name, atlas), x, y, alpha=alpha, tint=tint)
drawImage(ctx::Cairo.CairoContext, name::String, x::Number, y::Number; alpha::Number=getGlobalAlpha(), tint::Union{Nothing, rgbaTupleType}=nothing, atlas::String="Gameplay") = drawImage(ctx, getSprite(name, atlas), x, y, alpha=alpha, tint=tint)
drawImage(canvas::Gtk.GtkCanvas, sprite::Sprite, x::Number, y::Number; alpha::Number=getGlobalAlpha(), tint::Union{Nothing, rgbaTupleType}=nothing) = drawImage(Gtk.getgc(canvas), sprite, x, y, alpha=alpha, tint=tint)

function drawImage(ctx::Cairo.CairoContext, sprite::Sprite, x::Number, y::Number; alpha::Number=getGlobalAlpha(), tint::Union{Nothing, rgbaTupleType}=nothing)
    drawImage(ctx, sprite, x, y, 0, 0, Int(sprite.width), Int(sprite.height), alpha=alpha, tint=tint)
end

# TODO - Only scale 1/-1 works as intended
function drawSprite(ctx::Cairo.CairoContext, texture::String, x::Number, y::Number; jx::Number=0.5, jy::Number=0.5, sx::Number=1, sy::Number=1, rot::Number=0, alpha::Number=getGlobalAlpha(), tint::Union{Nothing, rgbaTupleType}=nothing, atlas::String="Gameplay")
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

# Create image from matrix
# Bitmap colors are 0 index based (false = 0, true = 1)
function matrixToSurface(bitmap::Array{T, 2}, colors::Array{rgbaTupleType, 1}=rgbaTupleType[(0.0, 0.0, 0.0, 1.0), (1.0, 1.0, 1.0, 1.0)]) where T <: Integer
    height, width = size(bitmap)
    pixels = width * height

    data = Array{Cairo.ARGB32, 1}(undef, pixels)

    ptr = 1
    for x in 1:width, y in 1:height
        data[ptr] = Cairo.ARGB32(colors[bitmap[y, x] + 1]...)

        ptr += 1
    end

    data = permutedims(reshape(data, (height, width)))

    return CairoImageSurface(data)
end

# Image tinting, super inefficient

function tintSurfaceAdditive(surface::Cairo.CairoSurface, color::rgbaTupleType, width::Number=width(surface), height::Number=height(surface))
    for x in 1:floor(Int, width), y in 1:floor(Int, height)
        pixelColor = argb32ToRGBATuple(surface.data[x, y]) ./ 255
        surface.data[x, y] = normRGBA32Tuple2ARGB32(min.(1.0, pixelColor .+ color))
    end

    return surface
end

function tintSurfaceMultiplicative(surface::Cairo.CairoSurface, color::rgbaTupleType, width::Number=width(surface), height::Number=height(surface))
    for x in 1:floor(Int, width), y in 1:floor(Int, height)
        pixelColor = argb32ToRGBATuple(surface.data[x, y]) ./ 255
        surface.data[x, y] = normRGBA32Tuple2ARGB32(pixelColor .* color)
    end

    return surface
end

# Shapes #

function setSourceColor(ctx, c::colorTupleType)
    return length(c) == 3 ? set_source_rgb(ctx, c...) : set_source_rgba(ctx, c...)
end

function paintSurface(ctx::Cairo.CairoContext, c::colorTupleType=(1.0, 1.0, 1.0, 1.0))
    setSourceColor(ctx, c)
    paint(ctx)
end

paintSurface(surface::Cairo.CairoSurface, c::colorTupleType=(1.0, 1.0, 1.0, 1.0)) = paintSurface(getSurfaceContext(surface), c)

function clearArea(ctx::Cairo.CairoContext, x::Integer, y::Integer, width::Integer, height::Integer)
    Cairo.save(ctx)

    setSourceColor(ctx, (0.0, 0.0, 0.0, 1.0))
    set_operator(ctx, Cairo.OPERATOR_CLEAR)
    rectangle(ctx, x, y, width, height)
    fill(ctx)

    restore(ctx)
end

clearSurface(surface::Cairo.CairoSurface, x::Integer, y::Integer, width::Integer, height::Integer) = clearSurface(getSurfaceContext(surface), x, y, width, height)

function clearSurface(ctx::Cairo.CairoContext)
    Cairo.save(ctx)

    setSourceColor(ctx, (0.0, 0.0, 0.0, 0.0))
    set_operator(ctx, Cairo.OPERATOR_SOURCE)
    paint(ctx)

    restore(ctx)
end

clearSurface(surface::Cairo.CairoSurface) = clearSurface(getSurfaceContext(surface))

# With border
function drawRectangle(ctx::Cairo.CairoContext, x::Number, y::Number, w::Number, h::Number, fc::colorTupleType=(0.0, 0.0, 0.0), rc::colorTupleType=(0.0, 0.0, 0.0, 0.0))
    Cairo.save(ctx)

    setSourceColor(ctx, fc)
    rectangle(ctx, x, y, w, h)
    fill_preserve(ctx)
    setSourceColor(ctx, rc)
    stroke(ctx)

    restore(ctx)
end

drawRectangle(ctx::Cairo.CairoContext, rect::Rectangle, fc::colorTupleType=(0.0, 0.0, 0.0), rc::colorTupleType=(0.0, 0.0, 0.0)) = drawRectangle(ctx, rect.x, rect.y, rect.w, rect.h, fc, rc)

function drawLines(ctx::Cairo.CairoContext, nodes::Array{T, 1}, sc::colorTupleType=(0.0, 0.0, 0.0); thickness::Integer=2, filled::Bool=false, fc::colorTupleType=sc) where T <: Tuple{Number, Number}
    if length(nodes) < 2
        return
    end

    Cairo.save(ctx)

    set_antialias(ctx, thickness)
    set_line_width(ctx, thickness)

    move_to(ctx, nodes[1]...)

    for node in nodes[2:end]
        line_to(ctx, node...)
    end
    
    if filled
        setSourceColor(ctx, fc)
        fill_preserve(ctx)
    end

    setSourceColor(ctx, sc)
    stroke(ctx)
    restore(ctx)
end

function drawSimpleCurve(ctx::Cairo.CairoContext, curve::SimpleCurve, c::colorTupleType=(0.0, 0.0, 0.0); resolution::Integer=25, thickness::Integer=2)
    points = [getPoint(curve, i / resolution) for i in 0:resolution]

    drawLines(ctx, points, c, thickness=thickness)
end

function drawArc(ctx::Cairo.CairoContext, x::Number, y::Number, r::Number, alpha::Number, beta::Number, c::colorTupleType=(0.0, 0.0, 0.0))
    Cairo.save(ctx)

    setSourceColor(ctx, c)
    arc(ctx, x, y, r, alpha, beta)
    stroke(ctx)

    restore(ctx)
end

function drawCircle(ctx::Cairo.CairoContext, x::Number, y::Number, r::Number, c::colorTupleType=(0.0, 0.0, 0.0))
    drawArc(ctx, x, y, r, 0, 2 * pi, c)
end

function drawArrow(ctx::Cairo.CairoContext, x1::Number, y1::Number, x2::Number, y2::Number, c::colorTupleType=(0.0, 0.0, 0.0); filled::Bool=true, headLength::Number=15, headTheta::Number=pi / 6)
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