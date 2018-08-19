module HangingLamp

using ..Ahorn, Maple

function hangingLampFinalizer(entity::Maple.Entity)
    nx, ny = Int.(entity.data["nodes"][1])
    y = Int(entity.data["y"])

    entity.data["height"] = abs(ny - y)
    
    delete!(entity.data, "nodes")
end

placements = Dict{String, Ahorn.EntityPlacement}(
    "Hanging Lamp" => Ahorn.EntityPlacement(
        Maple.HangingLamp,
        "line",
        Dict{String, Any}(),
        hangingLampFinalizer
    )
)

function minimumSize(entity::Maple.Entity)
    if entity.name == "hanginglamp"
        return true, 0, 8
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "hanginglamp"
        return true, false, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "hanginglamp"
        x, y = Ahorn.entityTranslation(entity)

        height = get(entity.data, "height", 16)

        return true, Ahorn.Rectangle(x + 1, y, 7, height)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "hanginglamp"
        Ahorn.drawImage(ctx, "objects/hanginglamp", 1, 0, 0, 0, 7, 3)

        height = get(entity.data, "height", 16)
        for i in 0:4:height - 11
            Ahorn.drawImage(ctx, "objects/hanginglamp", 1, i + 3, 0, 8, 7, 4)
        end

        Ahorn.drawImage(ctx, "objects/hanginglamp", 1, height - 8, 0, 16, 7, 8)

        return true
    end

    return false
end

end