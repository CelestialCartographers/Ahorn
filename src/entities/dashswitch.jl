module DashSwitch


placements = Dict{String, Main.EntityPlacement}()

textures = ["default", "mirror"]
directions = Dict{String, Tuple{Function, String, Bool}}(
    "up" => (Main.Maple.DashSwitchVertical, "ceiling", false),
    "down" => (Main.Maple.DashSwitchVertical, "ceiling", true),
    "left" => (Main.Maple.DashSwitchHorizontal, "leftSide", false),
    "right" => (Main.Maple.DashSwitchHorizontal, "leftSide", true),
)

for texture in textures
    for (dir, data) in directions
        key = "Dash Switch ($(titlecase(dir)), $(titlecase(texture)))"
        func, datakey, val = data
        placements[key] = Main.EntityPlacement(
            func,
            "rectangle",
            Dict{String, Any}(
                "sprite" => texture,
                datakey => val
            )
        )
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "dashSwitchH"
        x, y = Main.entityTranslation(entity)
        left = get(entity.data, "leftSide", false)

        if left
            return true, Main.Rectangle(x, y - 1, 10, 16)

        else
            return true, Main.Rectangle(x - 2, y, 10, 16)
        end

    elseif entity.name == "dashSwitchV"
        x, y = Main.entityTranslation(entity)
        ceiling = get(entity.data, "ceiling", false)

        if ceiling
            return true, Main.Rectangle(x, y, 16, 12)

        else
            return true, Main.Rectangle(x, y - 4, 16, 12)
        end
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "dashSwitchH"
        sprite = get(entity.data, "sprite", "default")
        left = get(entity.data, "leftSide", false)
        texture = sprite == "default"? "objects/temple/dashButton00.png" : "objects/temple/dashButtonMirror00.png"

        if left
            Main.drawSprite(ctx, texture, 20, 25, rot=pi)

        else
            Main.drawSprite(ctx, texture, 8, 8)
        end

        return true

    elseif entity.name == "dashSwitchV"
        sprite = get(entity.data, "sprite", "default")
        ceiling = get(entity.data, "ceiling", false)
        texture = sprite == "default"? "objects/temple/dashButton00.png" : "objects/temple/dashButtonMirror00.png"

        if ceiling
            Main.drawSprite(ctx, texture, 9, 20, rot=-pi / 2)

        else
            Main.drawSprite(ctx, texture, 27, 7, rot=pi / 2)
        end

        return true
    end

    return false
end

end