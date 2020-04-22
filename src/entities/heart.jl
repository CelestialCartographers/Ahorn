module Heart

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Crystal Heart" => Ahorn.EntityPlacement(
        Maple.CrystalHeart
    ),

    "Crystal Heart (Dream)" => Ahorn.EntityPlacement(
        Maple.DreamCrystalHeart
    ),

    "Crystal Heart (Fake)" => Ahorn.EntityPlacement(
        Maple.FakeCrystalHeart
    ),
)

Ahorn.editingOptions(entity::Maple.FakeCrystalHeart) = Dict{String, Any}(
    "color" => Maple.everest_fake_heart_colors
)

heartUnion = Union{Maple.CrystalHeart, Maple.DreamCrystalHeart, Maple.FakeCrystalHeart}

sprite = "collectables/heartGem/0/00.png"

function Ahorn.selection(entity::heartUnion)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::heartUnion, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, 0)

end