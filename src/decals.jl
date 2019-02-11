function position(decal::Maple.Decal)
    return (
        floor(Int, decal.x),
        floor(Int, decal.y)
    )
end

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

function drawDecal(ctx::Cairo.CairoContext, decal::Maple.Decal; alpha::Number=getGlobalAlpha())
    texture = "decals/$(decal.texture)"
    sprite = getTextureSprite(texture, "Gameplay")

    realWidth, realHeight = sprite.realWidth, sprite.realHeight
    width, height = sprite.width, sprite.height

    x, y = round(Int, decal.x), round(Int, decal.y)
    sx, sy = round(Int, decal.scaleX), round(Int, decal.scaleY)

    if width > 0 && height > 0
        Cairo.save(ctx)

        translate(ctx, x, y)
        scale(ctx, sx, sy)
        translate(ctx, -sprite.offsetX, -sprite.offsetY)
        translate(ctx, -realWidth / 2, -realHeight / 2)

        drawImage(ctx, sprite, 0, 0, alpha=alpha)
        
        restore(ctx)

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
    Ahorn.loadExternalSprites!()
    textures = Ahorn.spritesToDecalTextures(Ahorn.getAtlas("Gameplay"))

    if !animationFrames
        filter!(filterAnimations, textures)
    end

    sort!(textures)

    return textures
end

function decalConfigOptions(decal::Maple.Decal, ignores::Array{String, 1}=String[])
    res = Form.Option[]

    names = get(langdata, ["placements", "decals", "names"])
    tooltips = get(langdata, ["placements", "decals", "tooltips"])

    ignores = vcat("__name", ignores)
    data = Dict(decal)

    for (attr, value) in data
        if attr in ignores
            continue
        end

        name = expandTooltipText(get(names, Symbol(attr), ""))
        displayName = isempty(name) ? humanizeVariableName(attr) : name
        tooltip = expandTooltipText(get(tooltips, Symbol(attr), ""))
        textures = attr == "texture" ? decalTextures() : nothing
        
        push!(res, Form.suggestOption(displayName, value, dataName=attr, tooltip=tooltip, choices=textures, editable=true))
    end

    return res
end