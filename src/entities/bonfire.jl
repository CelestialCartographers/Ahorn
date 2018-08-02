module Bonfire

placements = Dict{String, Main.EntityPlacement}(
    "Bonfire" => Main.EntityPlacement(
        Main.Maple.Bonfire,
        "point"
    )
)

function editingOptions(entity::Main.Maple.Entity)
    if entity.name == "bonfire"
        return true, Dict{String, Any}(
            "mode" => Main.Maple.bonfire_modes
        )
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "bonfire"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 12, y - 16, 26, 16)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "bonfire"
        mode = lowercase(get(entity.data, "mode", "unlit"))

        if mode == "lit"
            Main.drawSprite(ctx, "objects/campfire/fire08.png", 0, -32)

        elseif mode == "smoking"
            Main.drawSprite(ctx, "objects/campfire/smoking04.png", 0, -32)

        else
            Main.drawSprite(ctx, "objects/campfire/fire00.png", 0, -32)
        end

        return true
    end

    return false
end

end