module NPC

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "NPC" => Ahorn.EntityPlacement(
        Maple.NPC
    )
)

Ahorn.editingOptions(entity::Maple.NPC) = Dict{String, Any}(
    "npc" => Maple.npc_npcs
)

npcSprites = Dict{String, String}(
    "granny" => "characters/oldlady/idle00",
    "theo" => "characters/theo/theo00",
    "oshiro" => "characters/oshiro/oshiro24",
    "evil" => "characters/badeline/sleep00",
    "badeline" => "characters/badeline/sleep00",
)

function getTexture(entity::Maple.NPC)
    npcName = get(entity.data, "npc", "granny_00_house")
    name = lowercase(split(npcName, "_")[1])

    return get(npcSprites, name, false)
end

function Ahorn.selection(entity::Maple.NPC)
    x, y = Ahorn.position(entity)
    sprite = getTexture(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y, jx=0.5, jy=1.0)
end

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.NPC, room::Maple.Room)
    texture = getTexture(entity)

    if isa(texture, String)
        Ahorn.drawSprite(ctx, texture, 0, 0, jx=0.5, jy=1.0)

        return true
    end

    return false
end

end