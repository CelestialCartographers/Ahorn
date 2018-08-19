module DashSwitch

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}()

textures = ["default", "mirror"]
directions = Dict{String, Tuple{Function, String, Bool}}(
    "up" => (Maple.DashSwitchVertical, "ceiling", false),
    "down" => (Maple.DashSwitchVertical, "ceiling", true),
    "left" => (Maple.DashSwitchHorizontal, "leftSide", false),
    "right" => (Maple.DashSwitchHorizontal, "leftSide", true),
)

for texture in textures
    for (dir, data) in directions
        key = "Dash Switch ($(titlecase(dir)), $(titlecase(texture)))"
        func, datakey, val = data
        placements[key] = Ahorn.EntityPlacement(
            func,
            "rectangle",
            Dict{String, Any}(
                "sprite" => texture,
                datakey => val
            )
        )
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "dashSwitchH"
        x, y = Ahorn.entityTranslation(entity)
        left = get(entity.data, "leftSide", false)

        if left
            return true, Ahorn.Rectangle(x, y - 1, 10, 16)

        else
            return true, Ahorn.Rectangle(x - 2, y, 10, 16)
        end

    elseif entity.name == "dashSwitchV"
        x, y = Ahorn.entityTranslation(entity)
        ceiling = get(entity.data, "ceiling", false)

        if ceiling
            return true, Ahorn.Rectangle(x, y, 16, 12)

        else
            return true, Ahorn.Rectangle(x, y - 4, 16, 12)
        end
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "dashSwitchH"
        sprite = get(entity.data, "sprite", "default")
        left = get(entity.data, "leftSide", false)
        texture = sprite == "default"? "objects/temple/dashButton00.png" : "objects/temple/dashButtonMirror00.png"

        if left
            Ahorn.drawSprite(ctx, texture, 20, 25, rot=pi)

        else
            Ahorn.drawSprite(ctx, texture, 8, 8)
        end

        return true

    elseif entity.name == "dashSwitchV"
        sprite = get(entity.data, "sprite", "default")
        ceiling = get(entity.data, "ceiling", false)
        texture = sprite == "default"? "objects/temple/dashButton00.png" : "objects/temple/dashButtonMirror00.png"

        if ceiling
            Ahorn.drawSprite(ctx, texture, 9, 20, rot=-pi / 2)

        else
            Ahorn.drawSprite(ctx, texture, 27, 7, rot=pi / 2)
        end

        return true
    end

    return false
end

end