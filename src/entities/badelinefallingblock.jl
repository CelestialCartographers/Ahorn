module BadelineFallingBlock

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Badeline Boss Falling Block" => Ahorn.EntityPlacement(
        Maple.BadelineFallingBlock,
        "rectangle",
    )
)

Ahorn.minimumSize(entity::Maple.BadelineFallingBlock) = 8, 8
Ahorn.resizable(entity::Maple.BadelineFallingBlock) = true, true

Ahorn.selection(entity::Maple.BadelineFallingBlock) = Ahorn.getEntityRectangle(entity)

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.BadelineFallingBlock, room::Maple.Room)
    Ahorn.drawTileEntity(ctx, room, entity, material='g')
end

end