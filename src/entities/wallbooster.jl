module WallBooster

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Wall Booster (Right)" => Ahorn.EntityPlacement(
        Maple.WallBooster,
        "rectangle",
        Dict{String, Any}(
            "left" => true
        )
    ),
    "Wall Booster (Left)" => Ahorn.EntityPlacement(
        Maple.WallBooster,
        "rectangle",
        Dict{String, Any}(
            "left" => false
        )
    )
)

function minimumSize(entity::Maple.Entity)
    if entity.name == "wallBooster"
        return true, 0, 8
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "wallBooster"
        return true, false, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "wallBooster"
        x, y = Ahorn.entityTranslation(entity)

        height = Int(get(entity.data, "height", 8))

        return true, Ahorn.Rectangle(x, y, 8, height)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "wallBooster"
        left = get(entity.data, "left", false)

        # Values need to be system specific integer
        x = Int(get(entity.data, "x", 0))
        y = Int(get(entity.data, "y", 0))

        height = Int(get(entity.data, "height", 8))
        tileHeight = div(height, 8)

        if left
            for i in 2:tileHeight - 1
                Ahorn.drawImage(ctx, "objects/wallBooster/fireMid00", 0, (i - 1) * 8)
            end

            Ahorn.drawImage(ctx, "objects/wallBooster/fireTop00", 0, 0)
            Ahorn.drawImage(ctx, "objects/wallBooster/fireBottom00", 0, (tileHeight - 1) * 8)

        else
            Ahorn.Cairo.save(ctx)
            Ahorn.scale(ctx, -1, 1)

            for i in 2:tileHeight - 1
                Ahorn.drawImage(ctx, "objects/wallBooster/fireMid00", -8, (i - 1) * 8)
            end

            Ahorn.drawImage(ctx, "objects/wallBooster/fireTop00", -8, 0)
            Ahorn.drawImage(ctx, "objects/wallBooster/fireBottom00", -8, (tileHeight - 1) * 8)

            Ahorn.restore(ctx)
        end

        return true
    end

    return false
end

end