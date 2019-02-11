module ForsakenCitySatellite

using ..Ahorn, Maple

function satelliteFinalizer(entity::Maple.ForsakenCitySatellite)
    x, y = Ahorn.position(entity)

    entity.data["nodes"] = [
        (x + 64, y),
        (x + 48, y),
    ]
end

const placements = Ahorn.PlacementDict(
    "Forsaken City Satellite" => Ahorn.EntityPlacement(
        Maple.ForsakenCitySatellite,
        "point",
        Dict{String, Any}(),
        satelliteFinalizer
    )
)

Ahorn.nodeLimits(entity::Maple.ForsakenCitySatellite) = 2, 2

birdSprite = "scenery/flutterbird/idle00.png"
gemSprite = "collectables/heartGem/0/00.png"

dishSprite = "objects/citysatellite/dish.png"
lightSprite = "objects/citysatellite/light.png"
computerSprite = "objects/citysatellite/computer.png"
computerScreenSprite = "objects/citysatellite/computerscreen.png"

# Offsets from game
computerOffsetX = 32
computerOffsetY = 24

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.ForsakenCitySatellite)
    x, y = Ahorn.position(entity)
    
    nodes = get(entity.data, "nodes", ((x, y), (x, y)))
    birdX, birdY = nodes[1]
    gemX, gemY = nodes[2]

    Ahorn.drawSprite(ctx, gemSprite, gemX, gemY)
    Ahorn.drawSprite(ctx, birdSprite, birdX, birdY, jx=0.5, jy=1.0)

    for node in nodes
        nx, ny = Int.(node)

        Ahorn.drawArrow(ctx, x, y, nx, ny, Ahorn.colors.selection_selected_fc, headLength=6)
    end
end

function Ahorn.selection(entity::Maple.ForsakenCitySatellite)
    x, y = Ahorn.position(entity)

    nodes = get(entity.data, "nodes", ((x, y), (x, y)))
    birdX, birdY = nodes[1]
    gemX, gemY = nodes[2]

    return [
        Ahorn.coverRectangles([
            Ahorn.getSpriteRectangle(dishSprite, x, y, jx=0.5, jy=1.0),
            Ahorn.getSpriteRectangle(lightSprite, x, y, jx=0.5, jy=1.0),
            Ahorn.getSpriteRectangle(computerSprite, x + computerOffsetX, y + computerOffsetY),
            Ahorn.getSpriteRectangle(computerScreenSprite, x + computerOffsetX, y + computerOffsetY)
        ]),
        Ahorn.getSpriteRectangle(birdSprite, birdX, birdY, jx=0.5, jy=1.0),
        Ahorn.getSpriteRectangle(gemSprite, gemX, gemY)
    ]
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.ForsakenCitySatellite, room::Maple.Room)
    x, y = Ahorn.position(entity)

    Ahorn.drawSprite(ctx, dishSprite, x, y, jx=0.5, jy=1.0)
    Ahorn.drawSprite(ctx, lightSprite, x, y, jx=0.5, jy=1.0)
    Ahorn.drawSprite(ctx, computerSprite, x + computerOffsetX, y + computerOffsetY)
    Ahorn.drawSprite(ctx, computerScreenSprite, x + computerOffsetX, y + computerOffsetY)
end

end