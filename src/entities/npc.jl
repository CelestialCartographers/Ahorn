module NPC

using ..Ahorn, Maple

npcSprites = Dict{String, String}(
    "granny" => "characters/oldlady/idle00",
    "theo" => "characters/theo/theo00",
    "oshiro" => "characters/oshiro/oshiro24",
    "evil" => "characters/badeline/sleep00",
    "badeline" => "characters/badeline/sleep00",
)

function getTexture(entity::Maple.Entity)
    npcName = get(entity.data, "npc", "granny_00_house")
    name = lowercase(split(npcName, "_")[1])

    return get(npcSprites, name, false)
end

function selection(entity::Maple.Entity)
    if entity.name == "npc"
        sprite = Ahorn.sprites[getTexture(entity)]

        x, y = Ahorn.entityTranslation(entity)
        w, h = sprite.width, sprite.height

        return true, Ahorn.Rectangle(x - floor(Int, w / 2), y - h, w, h)
    end
end

function render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "npc"
        texture = getTexture(entity)

        if isa(texture, String)
            sprite = Ahorn.sprites[texture]
            Ahorn.drawImage(ctx, sprite, -sprite.width / 2, -sprite.height)

            return true
        end
    end

    return false
end

end