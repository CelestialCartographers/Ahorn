module IntroCrusher

using ..Ahorn, Maple

placements = Dict{String, Ahorn.EntityPlacement}(
    "Intro Crusher" => Ahorn.EntityPlacement(
        Maple.IntroCrusher,
        "rectangle",
        Dict{String, Any}(),
        function(entity)
            entity.data["nodes"] = [(Int(entity.data["x"]) + Int(entity.data["width"]) + 8, Int(entity.data["y"]))]
        end
    ),
)

function nodeLimits(entity::Maple.Entity)
    if entity.name == "introCrusher"
        return true, 1, 1
    end
end

function minimumSize(entity::Maple.Entity)
    if entity.name == "introCrusher"
        return true, 8, 8
    end
end

function resizable(entity::Maple.Entity)
    if entity.name == "introCrusher"
        return true, true, true
    end
end

function selection(entity::Maple.Entity)
    if entity.name == "introCrusher"
        x, y = Ahorn.entityTranslation(entity)
        nx, ny = Int.(entity.data["nodes"][1])

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))

        return true, [Ahorn.Rectangle(x, y, width, height), Ahorn.Rectangle(nx, ny, width, height)]
    end
end

function renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "introCrusher"
        Ahorn.drawTileEntity(ctx, room, entity, material='3', blendIn=false)

        return true
    end

    return false
end

function renderSelectedAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity, room::Maple.Room)
    if entity.name == "introCrusher"
        x, y = Ahorn.entityTranslation(entity)
        nodes = get(entity.data, "nodes", ())

        width = Int(get(entity.data, "width", 8))
        height = Int(get(entity.data, "height", 8))
        
        if !isempty(nodes)
            nx, ny = Int.(nodes[1])
            cox, coy = floor(Int, width / 2), floor(Int, height / 2)

            fakeTiles = Ahorn.createFakeTiles(room, nx, ny, width, height, '3', blendIn=false)
            Ahorn.drawFakeTiles(ctx, room, fakeTiles, true, nx, ny, clipEdges=true)
            Ahorn.drawArrow(ctx, x + cox, y + coy, nx + cox, ny + coy, Ahorn.colors.selection_selected_fc, headLength=6)
        end
    end
end

end