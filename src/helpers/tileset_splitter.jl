module TilesetSplitter

using ..Ahorn
using Cairo

const tilesetCache = WeakKeyDict{Ahorn.Sprite, Array{Ahorn.Sprite, 2}}()

function generateTilesetSpriteMatrix(sprite::Ahorn.Sprite, tileWidth=8, tileHeight=8)
    if sprite.width % tileWidth != 0.0 sprite.height % tileHeight != 0.0
        error("Width and height must be divisible by tileWidth and tileHeight respectively.")
    end

    chunksX, chunksY = floor(Int, sprite.width / tileWidth), floor(Int, sprite.height / tileHeight)

    res = Array{Ahorn.Sprite, 2}(undef, chunksY, chunksX)

    for x in 0:1:chunksX - 1, y in 0:1:chunksY - 1
        surface = CairoARGBSurface(tileWidth, tileHeight)
        ctx = Ahorn.getSurfaceContext(surface)

        Ahorn.drawImage(ctx, sprite.surface, 0, 0, sprite.x + x * tileWidth, sprite.y + y * tileHeight, tileWidth, tileHeight)

        res[y + 1, x + 1] = Ahorn.Sprite(
            0,
            0,

            tileWidth,
            tileHeight,

            sprite.offsetX,
            sprite.offsetY,

            tileWidth,
            tileHeight,

            surface,
            sprite.filename
        )
    end

    return res
end

function getTilesetSpriteMatrix(sprite::Ahorn.Sprite, tileWidth=8, tileHeight=8)
    get!(tilesetCache, sprite) do
        return generateTilesetSpriteMatrix(sprite, tileWidth, tileHeight)
    end
end

end