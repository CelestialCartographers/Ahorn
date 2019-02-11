module HangingLamp

using ..Ahorn, Maple

function hangingLampFinalizer(entity::Maple.HangingLamp)
    nx, ny = Int.(entity.data["nodes"][1])
    y = Int(entity.data["y"])

    entity.data["height"] = max(abs(ny - y), 8)
    
    delete!(entity.data, "nodes")
end

const placements = Ahorn.PlacementDict(
    "Hanging Lamp" => Ahorn.EntityPlacement(
        Maple.HangingLamp,
        "line",
        Dict{String, Any}(),
        hangingLampFinalizer
    )
)

Ahorn.minimumSize(entity::Maple.HangingLamp) = 0, 8
Ahorn.resizable(entity::Maple.HangingLamp) = false, true

function Ahorn.selection(entity::Maple.HangingLamp)
    x, y = Ahorn.position(entity)
    height = get(entity.data, "height", 16)

    return Ahorn.Rectangle(x + 1, y, 7, height)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.HangingLamp, room::Maple.Room)
    Ahorn.drawImage(ctx, "objects/hanginglamp", 1, 0, 0, 0, 7, 3)

    height = get(entity.data, "height", 16)
    for i in 0:4:height - 11
        Ahorn.drawImage(ctx, "objects/hanginglamp", 1, i + 3, 0, 8, 7, 4)
    end

    Ahorn.drawImage(ctx, "objects/hanginglamp", 1, height - 8, 0, 16, 7, 8)
end

end