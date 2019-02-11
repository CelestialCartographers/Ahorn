module CoreToggle

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
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

function switchSprite(entity::Maple.CoreFlag)
    onlyIce = get(entity.data, "onlyIce", false)
    onlyFire = get(entity.data, "onlyFire", false)

    if onlyIce
        return "objects/coreFlipSwitch/switch13.png"

    elseif onlyFire
        return "objects/coreFlipSwitch/switch15.png"

    else
        return "objects/coreFlipSwitch/switch01.png"
    end
end

function Ahorn.selection(entity::Maple.CoreFlag)
    x, y = Ahorn.position(entity)
    sprite = switchSprite(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.CoreFlag, room::Maple.Room)
    sprite = switchSprite(entity)

    Ahorn.drawSprite(ctx, sprite, 0, 0)
end

end