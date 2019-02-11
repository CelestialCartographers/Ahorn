module Strawberry

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Strawberry" => Ahorn.EntityPlacement(
        Maple.Strawberry
    ),
    "Golden Strawberry" => Ahorn.EntityPlacement(
        Maple.GoldenStrawberry
    ),

    "Strawberry (Winged)" => Ahorn.EntityPlacement(
        Maple.Strawberry,
        "point",
        Dict{String, Any}(
            "winged" => true
        )
    ),
    "Golden Strawberry (Winged)" => Ahorn.EntityPlacement(
        Maple.GoldenStrawberry,
        "point",
        Dict{String, Any}(
            "winged" => true
        )
    ),

    "Golden Strawberry (Winged, No Dash)" => Ahorn.EntityPlacement(
        Maple.GoldenStrawberryNoDash,
        "point",
    ),
)

strawberryUnion = Union{Maple.Strawberry, Maple.GoldenStrawberry, Maple.GoldenStrawberryNoDash}

# name, winged, has pips
sprites = Dict{Tuple{String, Bool, Bool}, String}(
    ("strawberry", false, false) => "collectables/strawberry/normal00.png",
    ("strawberry", true, false) => "collectables/strawberry/wings01.png",
    ("strawberry", false, true) => "collectables/ghostberry/idle00.png",
    ("strawberry", true, true) => "collectables/ghostberry/wings01.png",

    ("goldenBerry", false, false) => "collectables/goldberry/idle00.png",
    ("goldenBerry", true, false) => "collectables/goldberry/wings01.png",
    ("goldenBerry", false, true) => "collectables/ghostgoldberry/idle00.png",
    ("goldenBerry", true, true) => "collectables/ghostgoldberry/wings01.png",

    ("memorialTextController", true, false) => "collectables/goldberry/wings01.png",
    ("memorialTextController", true, true) => "collectables/goldberry/wings01.png",
)

seeds = Dict{String, String}(
    "strawberry" => "collectables/strawberry/seed00.png",
    "goldenBerry" => "collectables/goldberry/seed00.png",
    "memorialTextController" => "collectables/goldberry/seed00.png",
)

Ahorn.nodeLimits(entity::strawberryUnion) = 0, -1

function Ahorn.selection(entity::strawberryUnion)
    x, y = Ahorn.position(entity)

    nodes = get(entity.data, "nodes", ())
    winged = get(entity.data, "winged", false) || entity.name == "memorialTextController"
    hasPips = length(nodes) > 0

    sprite = sprites[(entity.name, winged, hasPips)]
    seedSprite = seeds[entity.name]

    res = Ahorn.Rectangle[Ahorn.getSpriteRectangle(sprite, x, y)]
    
    for node in nodes
        nx, ny = node

        push!(res, Ahorn.getSpriteRectangle(seedSprite, nx, ny))
    end

    return res
end

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::strawberryUnion)
    x, y = Ahorn.position(entity)

    for node in get(entity.data, "nodes", ())
        nx, ny = node

        Ahorn.drawLines(ctx, Tuple{Number, Number}[(x, y), (nx, ny)], Ahorn.colors.selection_selected_fc)
    end
end

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::strawberryUnion, room::Maple.Room)
    x, y = Ahorn.position(entity)

    nodes = get(entity.data, "nodes", ())
    winged = get(entity.data, "winged", false) || entity.name == "memorialTextController"
    hasPips = length(nodes) > 0

    sprite = sprites[(entity.name, winged, hasPips)]
    seedSprite = seeds[entity.name]

    for node in nodes
        nx, ny = node

        Ahorn.drawSprite(ctx, seedSprite, nx, ny)
    end

    Ahorn.drawSprite(ctx, sprite, x, y)
end

end