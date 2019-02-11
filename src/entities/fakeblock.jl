module FakeBlock

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Fake Block" => Ahorn.EntityPlacement(
        Maple.FakeBlock,
        "rectangle",
        Dict{String, Any}(),
        Ahorn.tileEntityFinalizer
    ),
)

Ahorn.editingOptions(entity::Maple.FakeBlock) = Dict{String, Any}(
    "tiletype" => Ahorn.tiletypeEditingOptions()
)

Ahorn.minimumSize(entity::Maple.FakeBlock) = 8, 8
Ahorn.resizable(entity::Maple.FakeBlock) = true, true

Ahorn.selection(entity::Maple.FakeBlock) = Ahorn.getEntityRectangle(entity)

Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.FakeBlock, room::Maple.Room) = Ahorn.drawTileEntity(ctx, room, entity, alpha=0.7)

end