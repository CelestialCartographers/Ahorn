module SummitCloud

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Summit Cloud" => Ahorn.EntityPlacement(
        Maple.SummitCloud
    )
)

function Ahorn.selection(entity::Maple.SummitCloud)
    x, y = Ahorn.position(entity)

    rng = Ahorn.getSimpleEntityRng(entity)

    sprite = rand(rng, textures)
    scaleX = rand(rng, Int[-1, 1])

    return Ahorn.getSpriteRectangle(sprite, x, y, sx=scaleX, sy=1)
end

textures = String[
    "scenery/summitclouds/cloud00.png",
    "scenery/summitclouds/cloud01.png",
    "scenery/summitclouds/cloud03.png"
]

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.SummitCloud, room::Maple.Room)
    Ahorn.Cairo.save(ctx)

    rng = Ahorn.getSimpleEntityRng(entity)

    sprite = rand(rng, textures)
    scaleX = rand(rng, Int[-1, 1])
    
    Ahorn.Cairo.scale(ctx, scaleX, 1)
    Ahorn.drawSprite(ctx, sprite, 0, 0)

    Ahorn.Cairo.restore(ctx)
end

end