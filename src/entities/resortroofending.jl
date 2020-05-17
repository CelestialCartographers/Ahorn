module ResortRoofEnding

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Resort Roof Ending" => Ahorn.EntityPlacement(
        Maple.ResortRoofEnding,
        "rectangle"
    )
)

Ahorn.minimumSize(entity::Maple.ResortRoofEnding) = 8, 0
Ahorn.resizable(entity::Maple.ResortRoofEnding) = true, false

function Ahorn.selection(entity::Maple.ResortRoofEnding)
    x, y = Ahorn.position(entity)
    width = get(entity.data, "width", 8)

    return Ahorn.Rectangle(x, y, ceil(Int, width / 16) * 16 + 16, 16)
end

const centerTextures = String[
    "decals/3-resort/roofCenter.png",
    "decals/3-resort/roofCenter_b.png",
    "decals/3-resort/roofCenter_c.png",
    "decals/3-resort/roofCenter_d.png",
]

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.ResortRoofEnding, room::Maple.Room)
    rng = Ahorn.getSimpleEntityRng(entity)

    width = get(entity.data, "width", 8)
    Ahorn.drawSprite(ctx, "decals/3-resort/roofEdge_d.png", 8, 4)

    offset = 0
    while offset < width
        Ahorn.drawSprite(ctx, rand(rng, centerTextures), offset + 8, 4)

        offset += 16
    end

    Ahorn.drawSprite(ctx, "decals/3-resort/roofEdge.png", offset + 8, 4)
end

end