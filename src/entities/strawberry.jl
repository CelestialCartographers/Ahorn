module Strawberry

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
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
)

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
)

seeds = Dict{String, String}(
    "strawberry" => "collectables/strawberry/seed00.png",
    "goldenBerry" => "collectables/goldberry/seed00.png",
)

function nodeLimits(entity::Maple.Entity)
    if entity.name == "strawberry" || entity.name == "goldenBerry"
        return true, 0, -1
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "strawberry" || entity.name == "goldenBerry"
        nodes = get(entity.data, "nodes", ())
        x, y = Ahorn.entityTranslation(entity)

        res = Ahorn.Rectangle[Ahorn.Rectangle(x - 8, y - 8, 16, 16)]
        
        for node in nodes
            nx, ny = node

            push!(res, Ahorn.Rectangle(nx - 6, ny - 6, 12, 12))
        end

        return true, res
    end
end

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity)
    if entity.name == "strawberry" || entity.name == "goldenBerry"
        x, y = Ahorn.entityTranslation(entity)

        for node in get(entity.data, "nodes", ())
            nx, ny = node

            Ahorn.drawLines(ctx, Tuple{Number, Number}[(x, y), (nx, ny)], Ahorn.colors.selection_selected_fc)
        end
    end
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "strawberry" || entity.name == "goldenBerry"
        x, y = Ahorn.entityTranslation(entity)

        nodes = get(entity.data, "nodes", ())
        winged = get(entity.data, "winged", false)
        hasPips = length(nodes) > 0

        sprite = sprites[(entity.name, winged, hasPips)]
        seedSprite = seeds[entity.name]

        for node in nodes
            nx, ny = node

            Ahorn.drawSprite(ctx, seedSprite, nx, ny)
        end

        Ahorn.drawSprite(ctx, sprite, x, y)

        return true
    end

    return false
end

end