module HangingLamp

function hangingLampFinalizer(entity::Main.Maple.Entity)
    nx, ny = Int.(entity.data["nodes"][1])
    y = Int(entity.data["y"])

    entity.data["height"] = abs(ny - y)
    
    delete!(entity.data, "nodes")
end

placements = Dict{String, Main.EntityPlacement}(
    "Hanging Lamp" => Main.EntityPlacement(
        Main.Maple.HangingLamp,
        "line",
        Dict{String, Any}(),
        hangingLampFinalizer
    )
)

function minimumSize(entity::Main.Maple.Entity)
    if entity.name == "hanginglamp"
        return true, 0, 8
    end
end

function resizable(entity::Main.Maple.Entity)
    if entity.name == "hanginglamp"
        return true, false, true
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "hanginglamp"
        x, y = Main.entityTranslation(entity)

        height = get(entity.data, "height", 16)

        return true, Main.Rectangle(x + 1, y, 7, height)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "hanginglamp"
        Main.drawImage(ctx, "objects/hanginglamp", 1, 0, 0, 0, 7, 3)

        height = get(entity.data, "height", 16)
        for i in 0:4:height - 11
            Main.drawImage(ctx, "objects/hanginglamp", 1, i + 3, 0, 8, 7, 4)
        end

        Main.drawImage(ctx, "objects/hanginglamp", 1, height - 8, 0, 16, 7, 8)

        return true
    end

    return false
end

end