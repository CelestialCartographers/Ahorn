module CoreToggle

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Core Mode Toggle (Fire)" => Ahorn.EntityPlacement(
        Maple.CoreFlag,
        "point",
        Dict{String, Any}(
            "onlyFire" => true
        )
    ),
    "Core Mode Toggle (Ice)" => Ahorn.EntityPlacement(
        Maple.CoreFlag,
        "point",
        Dict{String, Any}(
            "onlyIce" => true
        )
    ),
    "Core Mode Toggle (Both)" => Ahorn.EntityPlacement(
        Maple.CoreFlag
    ),
)

function selection(entity::Maple.Entity)
    if entity.name == "coreModeToggle"
        x, y = Ahorn.entityTranslation(entity)

        return true, Ahorn.Rectangle(x - 8, y - 6, 16, 20)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "coreModeToggle"
        onlyIce = get(entity.data, "onlyIce", false)
        onlyFire = get(entity.data, "onlyFire", false)
        
        if onlyIce
            Ahorn.drawSprite(ctx, "objects/coreFlipSwitch/switch13.png", 0, 0)

        elseif onlyFire
            Ahorn.drawSprite(ctx, "objects/coreFlipSwitch/switch15.png", 0, 0)

        else
            Ahorn.drawSprite(ctx, "objects/coreFlipSwitch/switch01.png", 0, 0)
        end

        return true
    end

    return false
end

end