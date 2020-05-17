module Strawberry

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Strawberry" => Ahorn.EntityPlacement(
        Maple.Strawberry
    ),
    "Golden Strawberry" => Ahorn.EntityPlacement(
        Maple.GoldenStrawberry
    ),
    "Space Berry" => Ahorn.EntityPlacement(
        Maple.Strawberry,
        "point",
        Dict{String, Any}(
            "moon" => true
        )
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

const strawberryUnion = Union{Maple.Strawberry, Maple.GoldenStrawberry, Maple.GoldenStrawberryNoDash}

# name, winged, has pips, moon
const sprites = Dict{Tuple{String, Bool, Bool, Bool}, String}(
    ("strawberry", false, false, false) => "collectables/strawberry/normal00",
    ("strawberry", true, false, false) => "collectables/strawberry/wings01",
    ("strawberry", false, true, false) => "collectables/ghostberry/idle00",
    ("strawberry", true, true, false) => "collectables/ghostberry/wings01",

    ("strawberry", false, false, true) => "collectables/moonBerry/normal00",
    ("strawberry", true, false, true) => "collectables/moonBerry/ghost00",
    ("strawberry", false, true, true) => "collectables/moonBerry/ghost00",
    ("strawberry", true, true, true) => "collectables/moonBerry/ghost00",

    ("goldenBerry", false, false, false) => "collectables/goldberry/idle00",
    ("goldenBerry", true, false, false) => "collectables/goldberry/wings01",
    ("goldenBerry", false, true, false) => "collectables/ghostgoldberry/idle00",
    ("goldenBerry", true, true, false) => "collectables/ghostgoldberry/wings01",

    ("memorialTextController", true, false, false) => "collectables/goldberry/wings01",
    ("memorialTextController", true, true, false) => "collectables/goldberry/wings01",
)

const seeds = Dict{String, String}(
    "strawberry" => "collectables/strawberry/seed00",
    "goldenBerry" => "collectables/goldberry/seed00",
    "memorialTextController" => "collectables/goldberry/seed00",
)

const fallback = "collectables/strawberry/normal00"

Ahorn.nodeLimits(entity::strawberryUnion) = 0, -1

function Ahorn.selection(entity::strawberryUnion)
    x, y = Ahorn.position(entity)

    nodes = get(entity.data, "nodes", ())
    moon = get(entity.data, "moon", false)
    winged = get(entity.data, "winged", false) || entity.name == "memorialTextController"
    hasPips = length(nodes) > 0

    sprite = sprites[(entity.name, winged, hasPips, moon)]
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
    moon = get(entity.data, "moon", false)
    winged = get(entity.data, "winged", false) || entity.name == "memorialTextController"
    hasPips = length(nodes) > 0

    sprite = sprites[(entity.name, winged, hasPips, moon)]
    seedSprite = seeds[entity.name]

    for node in nodes
        nx, ny = node

        Ahorn.drawSprite(ctx, seedSprite, nx, ny)
    end

    Ahorn.drawSprite(ctx, sprite, x, y)
end

end