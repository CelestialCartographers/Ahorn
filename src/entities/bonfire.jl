module Bonfire

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Bonfire" => Ahorn.EntityPlacement(
        Maple.Bonfire,
        "point"
    )
)

function editingOptions(entity::Maple.Entity)
    if entity.name == "bonfire"
        return true, Dict{String, Any}(
            "mode" => Maple.bonfire_modes
        )
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "bonfire"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 12, y - 16, 26, 16)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "bonfire"
        mode = lowercase(get(entity.data, "mode", "unlit"))

        if mode == "lit"
            Ahorn.drawSprite(ctx, "objects/campfire/fire08.png", 0, -32)

        elseif mode == "smoking"
            Ahorn.drawSprite(ctx, "objects/campfire/smoking04.png", 0, -32)

        else
            Ahorn.drawSprite(ctx, "objects/campfire/fire00.png", 0, -32)
        end

        return true
    end

    return false
end

end