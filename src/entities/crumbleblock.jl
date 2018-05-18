module CrumbleBlock

placements = Dict{String, Main.EntityPlacement}(
    "Crumble Blocks" => Main.EntityPlacement(
        Main.Maple.CrumbleBlock,
        "rectangle",
    )
)

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "crumbleBlock"
        return true, 8, 0
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "crumbleBlock"
        return true, true, false
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "crumbleBlock"
        x, y = Main.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))

        return true, Main.Rectangle(x, y, width, 8)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "crumbleBlock"
        texture = get(entity.data, "texture", "wood")
        texture = texture == "default"? "wood" : texture

        # Values need to be system specific integer
        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))

        width = Int(get(entity.data, "width", 8))
        tilesWidth = div(width, 8)

        Main.Cairo.save(ctx)

        Main.rectangle(ctx, 0, 0, width, 8)
        Main.clip(ctx)

        for i in 0:ceil(Int, tilesWidth / 4)
            Main.drawImage(ctx, "objects/crumbleBlock/default", 32 * i, 0, 0, 0, 32, 8)
        end

        Main.restore(ctx)

        return true
    end

    return false
end

end