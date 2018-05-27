function decalSelection(decal::Maple.Decal)
    sprite = getTextureSprite("decals/$(decal.texture)")

    offsetY = sprite.realHeight / 2 * (decal.scaleY < 0)

    x = floor(Int, decal.x - sprite.realWidth / 2 - sprite.offsetX)
    y = floor(Int, decal.y - sprite.realHeight / 2 - sprite.offsetY - offsetY)
    
    width = abs(sprite.width * decal.scaleX)
    height = abs(sprite.height * decal.scaleY)

    return Rectangle(
        Int(x),
        Int(y),
        Int(width),
        Int(height)
    )
end

function spritesToDecalTextures(sprites::Dict{String, Sprite})
    res = String[]

    for (path, sprite) in sprites
        if startswith(path, "decals/")
            push!(res, path[8:end])
        end
    end
    
    return res
end

drawDecal(ctx::Cairo.CairoContext, d::Decal; alpha::Number=getGlobalAlpha()) = drawSprite(ctx, "decals/$(d.texture)", round(Int, d.x), round(Int, d.y), sx=round(Int, d.scaleX), sy=round(Int, d.scaleY), alpha=alpha)