module BounceBlock

placements = Dict{String, Main.EntityPlacement}(
    "Bounce Block" => Main.EntityPlacement(
        Main.Maple.BounceBlock,
        "rectangle"
    ),
)

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "bounceBlock"
        return true, 16, 16
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "bounceBlock"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "bounceBlock"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 16))
        height = Int(get(entity.data, "height", 16))

        return true, Main.Rectangle(x, y, width, height)
    end
end

frame = "objects/BumpBlockNew/fire00"
crystalSprite = Main.sprites["objects/BumpBlockNew/fire_center00"]

# Not the prettiest code, but it works
function renderBounceBlock(ctx::Main.Cairo.CairoContext, x::Number, y::Number, width::Number, height::Number)
    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    Main.Cairo.save(ctx)

    Main.rectangle(ctx, 0, 0, width, height)
    Main.clip(ctx)

    for i in 0:ceil(Int, tilesWidth / 6)
        Main.drawImage(ctx, frame, i * 48 + 8, 0, 8, 0, 48, 8)
        Main.drawImage(ctx, frame, i * 48 + 8, height - 8, 8, 56, 48, 8)

        for j in 0:ceil(Int, tilesHeight / 6)
            Main.drawImage(ctx, frame, i * 48 + 8, j * 48 + 8, 8, 8, 48, 48)

            Main.drawImage(ctx, frame, 0, j * 48 + 8, 8, 0, 8, 48)
            Main.drawImage(ctx, frame, width - 8, j * 48 + 8, 56, 8, 8, 48)
        end
    end

    Main.drawImage(ctx, frame, 0, 0, 0, 0, 8, 8)
    Main.drawImage(ctx, frame, width - 8, 0, 56, 0, 8, 8)
    Main.drawImage(ctx, frame, 0, height - 8, 0, 56, 8, 8)
    Main.drawImage(ctx, frame, width - 8, height - 8, 56, 56, 8, 8)
    
    Main.drawImage(ctx, crystalSprite, div(width - crystalSprite.width, 2), div(height - crystalSprite.height, 2))

    Main.restore(ctx)
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
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