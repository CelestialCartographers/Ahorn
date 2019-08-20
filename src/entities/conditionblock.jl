module ConditionBlock

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Condition Block" => Ahorn.EntityPlacement(
        Maple.ConditionBlock,
        "rectangle",
        Dict{String, Any}(),
        Ahorn.tileEntityFinalizer
    ),
)
Ahorn.editingOptions(entity::Maple.ConditionBlock) = Dict{String, Any}(
    "tileType" => Ahorn.tiletypeEditingOptions(),
    "condition" => Maple.condition_block_conditions
)

Ahorn.minimumSize(entity::Maple.ConditionBlock) = 8, 8
Ahorn.resizable(entity::Maple.ConditionBlock) = true, true

Ahorn.selection(entity::Maple.ConditionBlock) = Ahorn.getEntityRectangle(entity)

Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.ConditionBlock, room::Maple.Room) = Ahorn.drawTileEntity(ctx, room, entity, alpha=0.7)

end