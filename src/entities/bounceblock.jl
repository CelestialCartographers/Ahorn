module BounceBlock

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Bounce Block" => Ahorn.EntityPlacement(
        Maple.BounceBlock,
        "rectangle"
    ),
)

function minimumSize(entity::Maple.Entity)
    if entity.name == "bounceBlock"
        return true, 16, 16
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "bounceBlock"
        return true, true, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "bounceBlock"
        x, y = Ahorn.entityTranslation(entity)

        width = Int(get(entity.data, "width", 16))
        height = Int(get(entity.data, "height", 16))

        return true, Ahorn.Rectangle(x, y, width, height)
    end
end

frameResource = "objects/BumpBlockNew/fire00"
crystalResource = "objects/BumpBlockNew/fire_center00"

# Not the prettiest code, but it works
function renderBounceBlock(ctx::Ahorn.Cairo.CairoContext, x::Number, y::Number, width::Number, height::Number)
    crystalSprite = Ahorn.sprites[crystalResource]
    
    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    Ahorn.Cairo.save(ctx)

    Ahorn.rectangle(ctx, 0, 0, width, height)
    Ahorn.clip(ctx)

    for i in 0:ceil(Int, tilesWidth / 6)
        Ahorn.drawImage(ctx, frame, i * 48 + 8, 0, 8, 0, 48, 8)

        for j in 0:ceil(Int, tilesHeight / 6)
            Ahorn.drawImage(ctx, frame, i * 48 + 8, j * 48 + 8, 8, 8, 48, 48)

            Ahorn.drawImage(ctx, frame, 0, j * 48 + 8, 0, 8, 8, 48)
            Ahorn.drawImage(ctx, frame, width - 8, j * 48 + 8, 56, 8, 8, 48)
        end

        Ahorn.drawImage(ctx, frame, i * 48 + 8, height - 8, 8, 56, 48, 8)
    end

    Ahorn.drawImage(ctx, frame, 0, 0, 0, 0, 8, 8)
    Ahorn.drawImage(ctx, frame, width - 8, 0, 56, 0, 8, 8)
    Ahorn.drawImage(ctx, frame, 0, height - 8, 0, 56, 8, 8)
    Ahorn.drawImage(ctx, frame, width - 8, height - 8, 56, 56, 8, 8)
    
    Ahorn.drawImage(ctx, crystalSprite, div(width - crystalSprite.width, 2), div(height - crystalSprite.height, 2))

    Ahorn.restore(ctx)
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "bounceBlock"
        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        renderBounceBlock(ctx, x, y, width, height)

        return true
    end

    return false
end

end