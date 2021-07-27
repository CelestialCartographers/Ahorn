function position(decal::Maple.Decal)::Tuple{Int, Int}
    return (
        floor(Int, decal.x),
        floor(Int, decal.y)
    )
end

editingOrder(decal::Maple.Decal) = String["x", "y", "scaleX", "scaleY", "texture"]
editingIgnored(decal::Maple.Decal, multiple::Bool=false) = multiple ? String["x", "y"] : String[]

deleted(decal::Maple.Decal, node::Int) = nothing

moved(decal::Maple.Decal) = nothing
moved(decal::Maple.Decal, x::Int, y::Int) = nothing

resized(decal::Maple.Decal) = nothing
resized(decal::Maple.Decal, width::Int, height::Int) = nothing

function flipped(decal::Maple.Decal, horizontal::Bool)
    if horizontal
        decal.scaleX *= -1

    else
        decal.scaleY *= -1
    end

    return true
end

rotated(decal::Maple.Decal, steps::Int) = nothing

function decalSelection(decal::Maple.Decal)
    texture = "decals/$(decal.texture)"
    sprite = getTextureSprite(texture)

    x, y = round(Int, decal.x), round(Int, decal.y)
    sx, sy = round(Int, decal.scaleX), round(Int, decal.scaleY)

    width, height = sprite.width, sprite.height
    realWidth, realHeight = sprite.realWidth, sprite.realHeight

    drawX, drawY = floor(Int, x - (realWidth / 2 + sprite.offsetX) * sx), floor(Int, y - (realHeight / 2 + sprite.offsetY) * sy)
    drawX += sx < 0 ? width * sx : 0
    drawY += sy < 0 ? height * sy : 0

    return Rectangle(drawX, drawY, width * abs(sx), height * abs(sy))
end

function drawDecal(ctx::Cairo.CairoContext, decal::Maple.Decal; alpha=nothing)
    texture = "decals/$(decal.texture)"
    sprite = getTextureSprite(texture, "Gameplay")

    realWidth, realHeight = sprite.realWidth, sprite.realHeight
    width, height = sprite.width, sprite.height

    x, y = round(Int, decal.x), round(Int, decal.y)
    sx, sy = round(Int, decal.scaleX), round(Int, decal.scaleY)

    if width > 0 && height > 0
        # Don't render with either scale being 0, causes permanent issues to the drawing context
        # For some reason this doesn't seem to be restored properly by restore
        if ctx.ptr != C_NULL && sx != 0 && sy != 0
            Cairo.save(ctx)

            translate(ctx, x, y)
            scale(ctx, sx, sy)
            translate(ctx, -sprite.offsetX, -sprite.offsetY)
            translate(ctx, -realWidth / 2, -realHeight / 2)

            drawImage(ctx, sprite, 0, 0, alpha=alpha)

            restore(ctx)
        end

    else
        debug.log("Couldn't render decal with texture '$texture' at ($x, $y)", "DRAWING_DECAL_MISSING")
    end
end

function spritesToDecalTextures(sprites::Dict{String, SpriteHolder})
    res = String[]

    for (path, spriteHolder) in sprites
        if startswith(path, "decals/")
            if spriteHolder.sprite.width > 0 && spriteHolder.sprite.height > 0
                push!(res, path[8:end])
            end
        end
    end

    return res
end

animationRegex = r"\D+0*?$"
filterAnimations(s::String) = occursin(animationRegex, s)

function decalTextures(animationFrames::Bool=false)
    Ahorn.loadChangedExternalSprites!()
    textures = Ahorn.spritesToDecalTextures(Ahorn.getAtlas("Gameplay"))

    if !animationFrames
        filter!(filterAnimations, textures)
    end

    sort!(textures)

    return textures
end

const preferredDecalTypes = Dict{String, Type}(
    "texture" => String,

    "x" => Number,
    "y" => Number,

    "scaleX" => Integer,
    "scaleY" => Integer
)

function propertyOptions(decal::Maple.Decal, ignores::Array{String, 1}=String[])
    res = Form.Option[]

    names = get(langdata, ["placements", "decals", "names"])
    tooltips = get(langdata, ["placements", "decals", "tooltips"])

    ignores = vcat("__name", ignores)
    data = Dict(decal)

    showEditingChoices = get(config, "show_decal_texture_dropdown", false)

    for (attr, value) in data
        if attr in ignores
            continue
        end

        name = expandTooltipText(get(names, Symbol(attr), ""))
        displayName = isempty(name) ? humanizeVariableName(attr) : name
        tooltip = expandTooltipText(get(tooltips, Symbol(attr), ""))
        textures = showEditingChoices && attr == "texture" ? decalTextures() : nothing
        preferredType = get(preferredDecalTypes, attr, typeof(value))

        push!(res, Form.suggestOption(displayName, value, dataName=attr, tooltip=tooltip, choices=textures, editable=true, preferredType=preferredType))
    end

    return res
end