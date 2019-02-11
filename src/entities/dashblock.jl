module DashBlock

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Dash Block" => Ahorn.EntityPlacement(
        Maple.DashBlock,
        "rectangle",
        Dict{String, Any}(),
        Ahorn.tileEntityFinalizer
    )
)

Ahorn.editingOptions(entity::Maple.DashBlock) = Dict{String, Any}(
    "tiletype" => Ahorn.tiletypeEditingOptions()
)

Ahorn.minimumSize(entity::Maple.DashBlock) = 8, 8
Ahorn.resizable(entity::Maple.DashBlock) = true, true

Ahorn.selection(entity::Maple.DashBlock) = Ahorn.getEntityRectangle(entity)

Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.DashBlock, room::Maple.Room) = Ahorn.drawTileEntity(ctx, room, entity)

end