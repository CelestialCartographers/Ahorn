module SeekerStatue

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Seeker Statue" => Ahorn.EntityPlacement(
        Maple.SeekerStatue,
        "point",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + 32, Int(entity.data["y"]))]
        end
    )
)

Ahorn.nodeLimits(entity::Maple.SeekerStatue) = 1, -1

Ahorn.editingOptions(entity::Maple.SeekerStatue) = Dict{String, Any}(
    "hatch" => Maple.seeker_statue_hatches
)

function Ahorn.selection(entity::Maple.SeekerStatue)
    nodes = get(entity.data, "nodes", ())
    x, y = Ahorn.position(entity)

    res = Ahorn.Rectangle[Ahorn.getSpriteRectangle(statueSprite, x, y)]
    
    for node in nodes
        nx, ny = node

        push!(res, Ahorn.getSpriteRectangle(monsterSprite, nx, ny))
    end

    return res
end

statueSprite = "decals/5-temple/statue_e.png"
monsterSprite = "characters/monsters/predator73.png"

function Ahorn.renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.SeekerStatue)
    px, py = Ahorn.position(entity)

    for node in get(entity.data, "nodes", ())
        nx, ny = Int.(node)

        Ahorn.drawArrow(ctx, px, py, nx, ny, Ahorn.colors.selection_selected_fc, headLength=6)
        Ahorn.drawSprite(ctx, monsterSprite, nx, ny)

        px, py = nx, ny
    end
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.SeekerStatue, room::Maple.Room) = Ahorn.drawSprite(ctx, statueSprite, 0, 0)

end