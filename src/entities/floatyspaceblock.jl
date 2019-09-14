module FloatySpaceBlock

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Floaty Space Block" => Ahorn.EntityPlacement(
        Maple.FloatySpaceBlock,
        "rectangle",
        Dict{String, Any}(),
        Ahorn.tileEntityFinalizer
    )
)

Ahorn.editingOptions(entity::Maple.FloatySpaceBlock) = Dict{String, Any}(
    "tiletype" => Ahorn.tiletypeEditingOptions()
)

Ahorn.minimumSize(entity::Maple.FloatySpaceBlock) = 8, 8
Ahorn.resizable(entity::Maple.FloatySpaceBlock) = true, true

Ahorn.selection(entity::Maple.FloatySpaceBlock) = Ahorn.getEntityRectangle(entity)

Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.FloatySpaceBlock, room::Maple.Room) = Ahorn.drawTileEntity(ctx, room, entity)

end