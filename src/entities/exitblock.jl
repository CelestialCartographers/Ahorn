module ExitBlock

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Exit Block" => Ahorn.EntityPlacement(
        Maple.ExitBlock,
        "rectangle",
        Dict{String, Any}(),
        Ahorn.tileEntityFinalizer
    ),
)

Ahorn.editingOptions(entity::Maple.ExitBlock) = Dict{String, Any}(
    "tileType" => Ahorn.tiletypeEditingOptions()
)

Ahorn.minimumSize(entity::Maple.ExitBlock) = 8, 8
Ahorn.resizable(entity::Maple.ExitBlock) = true, true

Ahorn.selection(entity::Maple.ExitBlock) = Ahorn.getEntityRectangle(entity)

Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.ExitBlock, room::Maple.Room) = Ahorn.drawTileEntity(ctx, room, entity, alpha=0.7)

end