module CoreToggle

placements = Dict{String, Main.EntityPlacement}(
    "Core Mode Toggle (Fire)" => Main.EntityPlacement(
        Main.Maple.CoreFlag,
        "point",
        Dict{String, Any}(
            "onlyFire" => true
        )
    ),
    "Core Mode Toggle (Ice)" => Main.EntityPlacement(
        Main.Maple.CoreFlag,
        "point",
        Dict{String, Any}(
            "onlyIce" => true
        )
    ),
    "Core Mode Toggle (Both)" => Main.EntityPlacement(
        Main.Maple.CoreFlag
    ),
)

function selection(entity::Main.Maple.Entity)
    if entity.name == "coreModeToggle"
        x, y = Main.entityTranslation(entity)

        return true, Main.Rectangle(x - 8, y - 6, 16, 20)
    end
end

function render(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "coreModeToggle"
        onlyIce = get(entity.data, "onlyIce", false)
        onlyFire = get(entity.data, "onlyFire", false)
        
        if onlyIce
            Main.drawSprite(ctx, "objects/coreFlipSwitch/switch13.png", 0, 8)

        elseif onlyFire
            Main.drawSprite(ctx, "objects/coreFlipSwitch/switch15.png", 0, 0)

        else
            Main.drawSprite(ctx, "objects/coreFlipSwitch/switch01.png", 0, 0)
        end

        return true
    end

    return false
end

end