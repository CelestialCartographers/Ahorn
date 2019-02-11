module FakeWall

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Fake Wall" => Ahorn.EntityPlacement(
        Maple.FakeWall,
        "rectangle",
        Dict{String, Any}(),
        Ahorn.tileEntityFinalizer
    ),
)

Ahorn.editingOptions(entity::Maple.FakeWall) = Dict{String, Any}(
    "tiletype" => Ahorn.tiletypeEditingOptions()
)

Ahorn.minimumSize(entity::Maple.FakeWall) = 8, 8
Ahorn.resizable(entity::Maple.FakeWall) = true, true

Ahorn.selection(entity::Maple.FakeWall) = Ahorn.getEntityRectangle(entity)

Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.FakeWall, room::Maple.Room) = Ahorn.drawTileEntity(ctx, room, entity, alpha=0.7)

end