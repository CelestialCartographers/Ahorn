module Checkpoint

using ..Ahorn, Maple

function getBgSprite(entity::Maple.ChapterCheckpoint)
    bg = get(entity, "bg", "")
    name = "objects/checkpoint/bg/$bg"

    if !isempty(bg)
        backgroundSprite = Ahorn.getSprite(name, "Gameplay")

        if backgroundSprite.width != 0 && backgroundSprite.height != 0
            return true, name
        end
    end

    return false, false
end

bgFallback = "objects/checkpoint/bg/1"
flashSprite = "objects/checkpoint/flash04"

function Ahorn.selection(entity::Maple.ChapterCheckpoint)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(bgFallback, x, y, jx=0.5, jy=1.0)
end

Ahorn.editingOptions(entity::Maple.ChapterCheckpoint) = Dict{String, Any}(
    "dreaming" => Dict{String, Any}(
        "Automatic" => nothing,
        "Dreaming" => true,
        "Awake" => false
    ),
    "inventory" => merge(
        Dict{String, Any}(
            "Automatic" => nothing
        ),
        Dict{String, Any}(
            inventory => inventory for inventory in Maple.inventories 
        )
    ),
    "coreMode" => merge(
        Dict{String, Any}(
            "Automatic" => nothing
        ),
        Dict{String, Any}(
            mode => mode for mode in Maple.core_modes
        )
    ),
)

function Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.ChapterCheckpoint, room::Maple.Room)
    exists, bgSprite = getBgSprite(entity)

    if exists
        Ahorn.drawSprite(ctx, bgSprite, 0, 0, jx=0.5, jy=1.0)
    end

    Ahorn.drawSprite(ctx, flashSprite, 0, 0, jx=0.5, jy=1.0)
end

end
