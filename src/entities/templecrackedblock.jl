module TempleCrackedBlock

placements = Dict{String, Main.EntityPlacement}(
    "Temple Cracked Block" => Main.EntityPlacement(
        Main.Maple.TempleCrackedBlock,
        "rectangle",
        Dict{String, Any}(
            "persistent" => false
        )
    ),
    "Temple Cracked Block (Persistent)" => Main.EntityPlacement(
        Main.Maple.TempleCrackedBlock,
        "rectangle",
        Dict{String, Any}(
            "persistent" => true
        )
    ),
)

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "templeCrackedBlock"
        return true, 16, 16
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "templeCrackedBlock"
        return true, true, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "templeCrackedBlock"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 16))
        height = Int(get(entity.data, "height", 16))

        return true, Main.Rectangle(x, y, width, height)
    end
end

frame = "objects/temple/breakBlock00"

# Not the prettiest code, but it works
function rendertempleCrackedBlock(ctx::Main.Cairo.CairoContext, x::Number, y::Number, width::Number, height::Number)
    tilesWidth = div(width, 8)
    tilesHeight = div(height, 8)

    Main.Cairo.save(ctx)

    Main.rectangle(ctx, 0, 0, width, height)
    Main.clip(ctx)

    for i in 0:ceil(Int, tilesWidth / 4)
        Main.drawImage(ctx, frame, i * 32 + 8, 0, 8, 0, 32, 8)

        for j in 0:ceil(Int, tilesHeight / 4)
            Main.drawImage(ctx, frame, i * 32 + 8, j * 32 + 8, 8, 8, 32, 32)

            Main.drawImage(ctx, frame, 0, j * 32 + 8, 0, 8, 8, 32)
            Main.drawImage(ctx, frame, width - 8, j * 32 + 8, 40, 8, 8, 32)
        end

        Main.drawImage(ctx, frame, i * 32 + 8, height - 8, 8, 40, 32, 8)
    end

    Main.drawImage(ctx, frame, 0, 0, 0, 0, 8, 8)
    Main.drawImage(ctx, frame, width - 8, 0, 40, 0, 8, 8)
    Main.drawImage(ctx, frame, 0, height - 8, 0, 40, 8, 8)
    Main.drawImage(ctx, frame, width - 8, height - 8, 40, 40, 8, 8)

    Main.restore(ctx)
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "templeCrackedBlock"
        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))

        width = Int(get(entity.data, "width", 32))
        height = Int(get(entity.data, "height", 32))

        rendertempleCrackedBlock(ctx, x, y, width, height)

        return true
    end

    return false
end

end