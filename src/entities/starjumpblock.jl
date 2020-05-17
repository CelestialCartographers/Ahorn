module StarJumpBlock

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Star Jump Block" => Ahorn.EntityPlacement(
        Maple.StarJumpBlock,
        "rectangle"
    ),
    "Star Climb Controller" => Ahorn.EntityPlacement(
        Maple.StarClimbController,
    ),
    "Star Climb Graphics Controller (Everest)" => Ahorn.EntityPlacement(
        Maple.StarClimbGraphicsController,
    ),
)

Ahorn.minimumSize(entity::Maple.StarJumpBlock) = 8, 8
Ahorn.resizable(entity::Maple.StarJumpBlock) = true, true

Ahorn.selection(entity::Maple.StarJumpBlock) = Ahorn.getEntityRectangle(entity)
    
function Ahorn.selection(entity::Maple.StarClimbController)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - 12, y - 12, 24, 24)
end

function Ahorn.selection(entity::Maple.StarClimbGraphicsController)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - 12, y - 12, 24, 24)
end

function getStarjumpRectangles(room::Maple.Room)
    entities = filter(e -> e.name == "starJumpBlock", room.entities)
    rects = Ahorn.Rectangle[
        Ahorn.Rectangle(
            Int(get(e.data, "x", 0)),
            Int(get(e.data, "y", 0)),
            Int(get(e.data, "width", 8)),
            Int(get(e.data, "height", 8))
        ) for e in entities
    ]

    return rects
end

# Is there a star block we should connect to at the offset?
function noAdjacent(entity::Maple.StarJumpBlock, ox::Integer, oy::Integer, rects::Array{Ahorn.Rectangle, 1})
    x, y = Ahorn.position(entity)

    rect = Ahorn.Rectangle(x + ox + 4, y + oy + 4, 1, 1)

    return !any(Ahorn.checkCollision.(rects, Ref(rect)))
end

const fillColor = (255, 255, 255, 255) ./ 255
const corners = String[
    "objects/starjumpBlock/corner00.png",
    "objects/starjumpBlock/corner01.png",
    "objects/starjumpBlock/corner02.png",
    "objects/starjumpBlock/corner03.png"
]
const edgeHs = String[
    "objects/starjumpBlock/edgeH00.png",
    "objects/starjumpBlock/edgeH01.png",
    "objects/starjumpBlock/edgeH02.png",
    "objects/starjumpBlock/edgeH03.png",
]
const edgeVs = String[
    "objects/starjumpBlock/edgeV00.png",
    "objects/starjumpBlock/edgeV01.png",
    "objects/starjumpBlock/edgeV02.png",
    "objects/starjumpBlock/edgeV03.png",
]
const leftRailings = String[
    "objects/starjumpBlock/leftrailing00.png"
    "objects/starjumpBlock/leftrailing01.png"
    "objects/starjumpBlock/leftrailing02.png"
    "objects/starjumpBlock/leftrailing03.png"
    "objects/starjumpBlock/leftrailing04.png"
    "objects/starjumpBlock/leftrailing05.png"
    "objects/starjumpBlock/leftrailing06.png"
]
const rightRailings = String[
    "objects/starjumpBlock/rightrailing00.png"
    "objects/starjumpBlock/rightrailing01.png"
    "objects/starjumpBlock/rightrailing02.png"
    "objects/starjumpBlock/rightrailing03.png"
    "objects/starjumpBlock/rightrailing04.png"
    "objects/starjumpBlock/rightrailing05.png"
    "objects/starjumpBlock/rightrailing06.png"
]
const railings = String[
    "objects/starjumpBlock/railing00.png"
    "objects/starjumpBlock/railing01.png"
    "objects/starjumpBlock/railing02.png"
    "objects/starjumpBlock/railing03.png"
    "objects/starjumpBlock/railing04.png"
    "objects/starjumpBlock/railing05.png"
    "objects/starjumpBlock/railing06.png"
]

function renderStarjumpBlock(ctx::Ahorn.Cairo.CairoContext, entity::Maple.StarJumpBlock, room::Maple.Room)
    starJumpRectangles = getStarjumpRectangles(room)
    rng = Ahorn.getSimpleEntityRng(entity)

    x, y = Ahorn.position(entity)

    width = Int(get(entity.data, "width", 32))
    height = Int(get(entity.data, "height", 32))

    # Horizontal Border
    w = 8
    while w < width - 8
        if noAdjacent(entity, w, -8, starJumpRectangles)
            edge = rand(rng, edgeHs)
            Ahorn.drawSprite(ctx, edge, w + 4, 4)

            rail = railings[mod1(floor(Int, (x + w) / 8), length(railings))]
            Ahorn.drawSprite(ctx, rail, w, -8, jx=0.0, jy=0.0)
        end

        if noAdjacent(entity, w, height, starJumpRectangles)
            texture = rand(rng, edgeHs)
            Ahorn.drawSprite(ctx, texture, w + 4, height - 4, sy=-1)
        end

        w += 8
    end

    # Vertical Border
    h = 8
    while h < height - 8
        if noAdjacent(entity, -8, h, starJumpRectangles)
            texture = rand(rng, edgeVs)
            Ahorn.drawSprite(ctx, texture, 4, h + 4, sx=-1)
        end

        if noAdjacent(entity, width, h, starJumpRectangles)
            texture = rand(rng, edgeVs)
            Ahorn.drawSprite(ctx, texture, width - 4, h + 4)
        end

        h += 8
    end

    # Top Left Corner
    if noAdjacent(entity, -8, 0, starJumpRectangles) && noAdjacent(entity, 0, -8, starJumpRectangles)
        corner = rand(rng, corners)
        Ahorn.drawSprite(ctx, corner, 4, 4, sx=-1)

        rail = leftRailings[mod1(floor(Int, (x + w) / 8), length(leftRailings))]
        Ahorn.drawSprite(ctx, rail, 0, -8, jx=0.0, jy=0.0)

    elseif noAdjacent(entity, -8, 0, starJumpRectangles)
        corner = rand(rng, edgeVs)
        Ahorn.drawSprite(ctx, corner, 4, 4, sx=-1)

    elseif noAdjacent(entity, 0, -8, starJumpRectangles)
        corner = rand(rng, edgeHs)
        Ahorn.drawSprite(ctx, corner, 4, 4, sx=-1)

        rail = leftRailings[mod1(floor(Int, (x + w) / 8), length(leftRailings))]
        Ahorn.drawSprite(ctx, rail, 0, -8, jx=0.0, jy=0.0)
    end

    # Top Right Corner
    if noAdjacent(entity, width, 0, starJumpRectangles) && noAdjacent(entity, width - 8, -8, starJumpRectangles)
        corner = rand(rng, corners)
        Ahorn.drawSprite(ctx, corner, width - 4, 4)

        rail = rightRailings[mod1(floor(Int, (x + w) / 8), length(rightRailings))]
        Ahorn.drawSprite(ctx, rail, width - 8, -8, jx=0.0, jy=0.0)

    elseif noAdjacent(entity, width, 0, starJumpRectangles)
        corner = rand(rng, edgeVs)
        Ahorn.drawSprite(ctx, corner, width - 4, 4)

    elseif noAdjacent(entity, width - 8, -8, starJumpRectangles)
        corner = rand(rng, edgeHs)
        Ahorn.drawSprite(ctx, corner, width - 4, 4)

        rail = rightRailings[mod1(floor(Int, (x + w) / 8), length(rightRailings))]
        Ahorn.drawSprite(ctx, rail, width - 8, -8, jx=0.0, jy=0.0)
    end

    # Bottom Left Corner
    if noAdjacent(entity, -8, height - 8, starJumpRectangles) && noAdjacent(entity, 0, height, starJumpRectangles)
        corner = rand(rng, corners)
        Ahorn.drawSprite(ctx, corner, 4, height - 4, sx=-1, sy=-1)

    elseif noAdjacent(entity, -8, height - 8, starJumpRectangles)
        corner = rand(rng, edgeVs)
        Ahorn.drawSprite(ctx, corner, 4, height - 4, sx=-1, sy=-1)

    elseif noAdjacent(entity, 0, height, starJumpRectangles)
        corner = rand(rng, edgeHs)
        Ahorn.drawSprite(ctx, corner, 4, height - 4, sx=-1, sy=-1)
    end

    # Bottom Right Corner
    if noAdjacent(entity, width, height - 8, starJumpRectangles) && noAdjacent(entity, width - 8, height, starJumpRectangles)
        corner = rand(rng, corners)
        Ahorn.drawSprite(ctx, corner, width - 4, height - 4, sy=-1)

    elseif noAdjacent(entity, width, height - 8, starJumpRectangles)
        corner = rand(rng, edgeVs)
        Ahorn.drawSprite(ctx, corner, width - 4, height - 4, sy=-1)

    elseif noAdjacent(entity, width - 8, height, starJumpRectangles)
        corner = rand(rng, edgeHs)
        Ahorn.drawSprite(ctx, corner, width - 4, height - 4, sy=-1)
    end
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.StarJumpBlock, room::Maple.Room) = renderStarjumpBlock(ctx, entity, room)
Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.StarClimbController, room::Maple.Room) = Ahorn.drawImage(ctx, Ahorn.Assets.northernLights, -12, -12)
Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.StarClimbGraphicsController, room::Maple.Room) = Ahorn.drawImage(ctx, Ahorn.Assets.northernLights, -12, -12)

end