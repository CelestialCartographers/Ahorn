module BadelineFallingBlock

using ..Ahorn, Maple

# We place a FallingBlock with some preset data instead
# But it might still exist from loading base game maps

const placements = Ahorn.PlacementDict(
    "Badeline Boss Falling Block" => Ahorn.EntityPlacement(
        Maple.BadelineFallingBlock,
        "rectangle",
    )
)

Ahorn.minimumSize(entity::Maple.Entity{:finalBossFallingBlock}) = 8, 8
Ahorn.resizable(entity::Maple.Entity{:finalBossFallingBlock}) = true, true

Ahorn.selection(entity::Maple.Entity{:finalBossFallingBlock}) = Ahorn.getEntityRectangle(entity)

function Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.Entity{:finalBossFallingBlock}, room::Maple.Room)
    Ahorn.drawTileEntity(ctx, room, entity, material='g')
end

end