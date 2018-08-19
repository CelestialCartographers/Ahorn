module CrumbleBlock

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Crumble Blocks" => Ahorn.EntityPlacement(
        Maple.CrumbleBlock,
        "rectangle",
    )
)

function minimumSize(entity::Maple.Entity)
    if entity.name == "crumbleBlock"
        return true, 8, 0
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "crumbleBlock"
        return true, true, false
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "crumbleBlock"
        x, y = Ahorn.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))

        return true, Ahorn.Rectangle(x, y, width, 8)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "crumbleBlock"
        texture = get(entity.data, "texture", "wood")
        texture = texture == "default"? "wood" : texture

        # Values need to be system specific integer
        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))

        width = Int(get(entity.data, "width", 8))
        tilesWidth = div(width, 8)

        Ahorn.Cairo.save(ctx)

        Ahorn.rectangle(ctx, 0, 0, width, 8)
        Ahorn.clip(ctx)

        for i in 0:ceil(Int, tilesWidth / 4)
            Ahorn.drawImage(ctx, "objects/crumbleBlock/default", 32 * i, 0, 0, 0, 32, 8)
        end

        Ahorn.restore(ctx)

        return true
    end

    return false
end

end