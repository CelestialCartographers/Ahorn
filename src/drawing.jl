include("extract_sprites_meta.jl")

sprites = loadSprites(joinpath(storageDirectory, "Gameplay.meta"), joinpath(storageDirectory, "Gameplay.png"))
MOD_CONTENT_GAMEPLAY = joinpath(config["celeste_dir"], "ModContent", "Graphics", "Atlases", "Gameplay")

drawingAlpha = 1

function addSprite!(name::String)
    surface = read_from_png("$MOD_CONTENT_GAMEPLAY/$name.png")
    sprites[name] = Sprite(
        0,
        0,

        Int(width(surface)),
        Int(height(surface)),

        0,
        0,
        Int(width(surface)),
        Int(height(surface)),

        surface
    )
end

# Gets a resource or loads a modded one
function getSprite(name::String)
    # Remove entry if its (0, 0) in size
    if haskey(sprites, name) && sprites[name].width == 0 && sprites[name].height == 0
        delete!(sprites, name)
    end

    if !haskey(sprites, name)
        addSprite!(name)
    end

    return sprites[name]
end

function loadExternalSprites!()
    celesteDir = config["celeste_dir"]
    gameplayPath = joinpath(celesteDir, "ModContent", "Graphics", "Atlases", "Gameplay")

    for (root, dir, files) in walkdir(gameplayPath)
        for file in files
            rawpath = joinpath(root, file)
            path = fixTexturePath(relpath(rawpath, gameplayPath))

            addSprite!(path)
        end
    end
end

# remove .png and convert to unix paths
function fixTexturePath(texture::String)
    return replace(Base.splitext(texture)[1], "\\", "/")
end

function getTextureSprite(texture::String)
    return getSprite(fixTexturePath(texture))
end

function setGlobalAlpha!(alpha::Number=1)
    global drawingAlpha = alpha
end

getGlobalAlpha() = drawingAlpha

# This is probably one of the stupid ways to do it.
# Look into this if it turns out being slow

# Image based #

function drawImage(ctx::Cairo.CairoContext, surface::Cairo.CairoSurface, x::Number, y::Number, quadX::Number, quadY::Number, width::Number, height::Number; alpha::Number=getGlobalAlpha())
    Cairo.save(ctx)

    rectangle(ctx, x, y, width, height)
    clip(ctx)

    set_source_surface(ctx, surface, x - quadX, y - quadY)
    pattern_set_filter(get_source(ctx), Cairo.FILTER_NEAREST)

    paint_with_alpha(ctx, alpha)

    restore(ctx)
end

function drawImage(ctx::Cairo.CairoContext, surface::Cairo.CairoSurface, x::Number, y::Number; alpha::Number=getGlobalAlpha())
    drawImage(ctx, surface, x, y, 0, 0, Int(surface.width), Int(surface.height); alpha=alpha)
end

drawImage(canvas::Gtk.GtkCanvas, name::String, x::Number, y::Number, quadX::Number, quadY::Number, width::Number, height::Number; alpha::Number=getGlobalAlpha()) = drawImage(canvas, getSprite(name), x, y, quadX, quadY, width, height, alpha=alpha)
drawImage(ctx::Cairo.CairoContext, name::String, x::Number, y::Number, quadX::Number, quadY::Number, width::Number, height::Number; alpha::Number=getGlobalAlpha()) = drawImage(ctx, getSprite(name), x, y, quadX, quadY, width, height, alpha=alpha)
drawImage(canvas::Gtk.GtkCanvas, sprite::Sprite, x::Number, y::Number, quadX::Number, quadY::Number, width::Number, height::Number; alpha::Number=getGlobalAlpha()) = drawImage(Gtk.getgc(canvas), sprite.surface, x, y, quadX, quadY, width, height, alpha=alpha)

function drawImage(ctx::Cairo.CairoContext, sprite::Sprite, x::Number, y::Number, quadX::Number, quadY::Number, width::Number, height::Number; alpha::Number=getGlobalAlpha())
    Cairo.save(ctx)

    rectangle(ctx, x, y, width, height)
    clip(ctx)

    set_source_surface(ctx, sprite.surface, x - quadX - sprite.x, y - quadY - sprite.y)
    pattern_set_filter(get_source(ctx), Cairo.FILTER_NEAREST)

    paint_with_alpha(ctx, alpha)

    restore(ctx)
end

drawImage(canvas::Gtk.GtkCanvas, name::String, x::Number, y::Number; alpha::Number=getGlobalAlpha()) = drawImage(canvas, getSprite(name), x, y, alpha=alpha)
drawImage(ctx::Cairo.CairoContext, name::String, x::Number, y::Number; alpha::Number=getGlobalAlpha()) = drawImage(ctx, getSprite(name), x, y, alpha=alpha)
drawImage(canvas::Gtk.GtkCanvas, sprite::Sprite, x::Number, y::Number; alpha::Number=getGlobalAlpha()) = drawImage(Gtk.getgc(canvas), image, x, y, alpha=alpha)

function drawImage(ctx::Cairo.CairoContext, sprite::Sprite, x::Number, y::Number; alpha::Number=getGlobalAlpha())
    drawImage(ctx, sprite, x, y, 0, 0, Int(sprite.width), Int(sprite.height), alpha=alpha)
end

function drawSprite(ctx::Cairo.CairoContext, texture::String, x::Number, y::Number; sx::Number=1, sy::Number=1, rot::Number=0, alpha::Number=getGlobalAlpha())
    sprite = getTextureSprite(texture)

    width, height = sprite.realWidth, sprite.realHeight
    drawX, drawY = floor(Int, x - width / 2 - sprite.offsetX) , floor(Int, y - height / 2 - sprite.offsetY)

    Cairo.save(ctx)
    
    scale(ctx, sx, sy)
    translate(ctx, sx > 0? 0 : -2 * x, sy > 0? 0 : -2 * y)
    translate(ctx, drawX, drawY)
    rotate(ctx, rot)
    drawImage(ctx, sprite, 0, 0, alpha=alpha)

    restore(ctx)
end

# Shapes #

colorTupleType = Union{NTuple{3, Float64}, NTuple{4, Float64}}
function setSourceColor(ctx, c::colorTupleType)
    return length(c) == 3? set_source_rgb(ctx, c...) : set_source_rgba(ctx, c...)
end

function paintSurface(ctx::Cairo.CairoContext, c::colorTupleType=(1.0, 1.0, 1.0, 1.0))
    setSourceColor(ctx, c)
    paint(ctx)
end

paintSurface(surface::Cairo.CairoSurface, c::colorTupleType=(1.0, 1.0, 1.0, 1.0)) = paintSurface(creategc(surface), c)

function clearSurface(ctx::Cairo.CairoContext)
    Cairo.save(ctx)

    setSourceColor(ctx, (0.0, 0.0, 0.0, 0.0))
    set_operator(ctx, Cairo.OPERATOR_SOURCE)
    paint(ctx)

    restore(ctx)
end

clearSurface(surface::Cairo.CairoSurface) = clearSurface(creategc(surface))

# Without border
function drawRectangle(ctx::Cairo.CairoContext, x::Number, y::Number, w::Number, h::Number, c::colorTupleType=(0.0, 0.0, 0.0))
    Cairo.save(ctx)

    setSourceColor(ctx, c)
    rectangle(ctx, x, y, w, h)
    fill(ctx)

    restore(ctx)
end

# With border
function drawRectangle(ctx::Cairo.CairoContext, x::Number, y::Number, w::Number, h::Number, fc::colorTupleType=(0.0, 0.0, 0.0), rc::colorTupleType=(0.0, 0.0, 0.0))
    Cairo.save(ctx)

    setSourceColor(ctx, fc)
    rectangle(ctx, x, y, w, h)
    fill_preserve(ctx)
    setSourceColor(ctx, rc)
    stroke(ctx)

    restore(ctx)
end


drawRectangle(ctx::Cairo.CairoContext, rect::Rectangle, fc::colorTupleType=(0.0, 0.0, 0.0), rc::colorTupleType=(0.0, 0.0, 0.0)) = drawRectangle(ctx, rect.x, rect.y, rect.w, rect.h, fc, rc)
drawRectangle(ctx::Cairo.CairoContext, rect::Rectangle, c::colorTupleType=(0.0, 0.0, 0.0)) = drawRectangle(ctx, rect.x, rect.y, rect.w, rect.h, c)

function drawLines(ctx::Cairo.CairoContext, nodes::Array{T, 1}, sc::colorTupleType=(0.0, 0.0, 0.0); filled::Bool=false, fc::colorTupleType=sc) where T <: Tuple{Number, Number}
    if length(nodes) < 2
        return
    end

    Cairo.save(ctx)

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

# Make this prettier
function centeredText(ctx::Cairo.CairoContext, s::String, x::Number, y::Number; fontsize::Number=8, fontface::String="Sans", c::colorTupleType=(0.0, 0.0, 0.0))
    Cairo.save(ctx);

    setSourceColor(ctx, c)
    select_font_face(ctx, fontface, Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL)
    set_font_size(ctx, fontsize)
    extents = text_extents(ctx, s)
    
    drawX = x - (extents[3] / 2 + extents[1])
    drawY = y - (extents[4] / 2 + extents[2])
    
    move_to(ctx, drawX, drawY)
    show_text(ctx, s)

    restore(ctx)
end

function drawArrow(ctx::Cairo.CairoContext, x1::Number, y1::Number, x2::Number, y2::Number, c::colorTupleType=(0.0, 0.0, 0.0); filled::Bool=true, headLength::Number=15, headTheta::Number=pi / 6)
    theta = atan2(y2 - y1, x2 - x1)
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