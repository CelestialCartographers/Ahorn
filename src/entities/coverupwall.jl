module CoverupWall

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Coverup Wall" => Ahorn.EntityPlacement(
        Maple.CoverupWall,
        "rectangle",
        Dict{String, Any}(),
        Ahorn.tileEntityFinalizer
    ),
)

Ahorn.editingOptions(entity::Maple.CoverupWall) = Dict{String, Any}(
    "tiletype" => Ahorn.tiletypeEditingOptions()
)

Ahorn.minimumSize(entity::Maple.CoverupWall) = 8, 8
Ahorn.resizable(entity::Maple.CoverupWall) = true, true

Ahorn.selection(entity::Maple.CoverupWall) = Ahorn.getEntityRectangle(entity)

Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.CoverupWall, room::Maple.Room) = Ahorn.drawTileEntity(ctx, room, entity, alpha=0.7)

end