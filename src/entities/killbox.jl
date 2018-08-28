module Killbox

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Killbox" => Ahorn.EntityPlacement(
        Maple.Killbox,
        "rectangle"
    ),
)

function minimumSize(entity::Maple.Entity)
    if entity.name == "killbox"
        return true, 8, 0
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "killbox"
        return true, true, false
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "killbox"
        x, y = Ahorn.entityTranslation(entity)

        width = Int(get(entity.data, "width", 8))
        height = 32

        return true, Ahorn.Rectangle(x, y, width, height)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "killbox"
        width = Int(get(entity.data, "width", 32))
        height = 32

        Ahorn.drawRectangle(ctx, 0, 0, width, height, (0.8, 0.4, 0.4, 0.8), (0.0, 0.0, 0.0, 0.0))

        return true
    end

    return false
end

end