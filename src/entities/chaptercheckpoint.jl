module Checkpoint

using ..Ahorn, Maple

sprite = "objects/checkpoint/flag16.png"

# Custom offset to render nicely
offsetY = -16

function Ahorn.selection(entity::Maple.ChapterCheckpoint)
    x, y = Ahorn.position(entity)

    return Ahorn.getSpriteRectangle(sprite, x, y + offsetY)
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
    )
)

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.ChapterCheckpoint, room::Maple.Room) = Ahorn.drawSprite(ctx, sprite, 0, offsetY)

end