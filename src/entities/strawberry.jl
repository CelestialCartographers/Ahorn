module Strawberry

placements = Dict{String, Main.EntityPlacement}(
    "Strawberry" => Main.EntityPlacement(
        Main.Maple.Strawberry
    ),
    "Golden Strawberry" => Main.EntityPlacement(
        Main.Maple.GoldenStrawberry
    ),

    "Strawberry (Winged)" => Main.EntityPlacement(
        Main.Maple.Strawberry,
        "point",
        Dict{String, Any}(
            "winged" => true
        )
    ),
    "Golden Strawberry (Winged)" => Main.EntityPlacement(
        Main.Maple.GoldenStrawberry,
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

function nodeLimits(entity::Main.Maple.Entity)
    if entity.name == "strawberry" || entity.name == "goldenBerry"
        return true, 0, -1
    end
end

function selection(entity::Main.Maple.Entity)
    if entity.name == "strawberry" || entity.name == "goldenBerry"
        nodes = get(entity.data, "nodes", ())
        x, y = Main.entityTranslation(entity)

        res = Main.Rectangle[Main.Rectangle(x - 8, y - 8, 16, 16)]
        
        for node in nodes
            nx, ny = node

            push!(res, Main.Rectangle(nx - 6, ny - 6, 12, 12))
        end

        return true, res
    end
end

function renderSelectedAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity)
    if entity.name == "strawberry" || entity.name == "goldenBerry"
        x, y = Main.entityTranslation(entity)

        for node in get(entity.data, "nodes", ())
            nx, ny = node

            Main.drawLines(ctx, Tuple{Number, Number}[(x, y), (nx, ny)], Main.colors.selection_selected_fc)
        end
    end
end

function renderAbs(ctx::Main.Cairo.CairoContext, entity::Main.Maple.Entity, room::Main.Maple.Room)
    if entity.name == "strawberry" || entity.name == "goldenBerry"
        x, y = Main.entityTranslation(entity)

        nodes = get(entity.data, "nodes", ())
        winged = get(entity.data, "winged", false)
        hasPips = length(nodes) > 0

        sprite = sprites[(entity.name, winged, hasPips)]
        seedSprite = seeds[entity.name]

        for node in nodes
            nx, ny = node

            Main.drawSprite(ctx, seedSprite, nx, ny)
        end

        Main.drawSprite(ctx, sprite, x, y)

        return true
    end

    return false
end

end