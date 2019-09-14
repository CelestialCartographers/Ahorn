module CrumbleWallOnRumble

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Crumble Wall on Rumble" => Ahorn.EntityPlacement(
        Maple.CrumbleWallOnRumble,
        "rectangle",
        Dict{String, Any}(),
        Ahorn.tileEntityFinalizer
    )
)

Ahorn.editingOptions(entity::Maple.CrumbleWallOnRumble) = Dict{String, Any}(
    "tiletype" => Ahorn.tiletypeEditingOptions()
)

Ahorn.minimumSize(entity::Maple.CrumbleWallOnRumble) = 8, 8
Ahorn.resizable(entity::Maple.CrumbleWallOnRumble) = true, true

Ahorn.selection(entity::Maple.CrumbleWallOnRumble) = Ahorn.getEntityRectangle(entity)

Ahorn.renderAbs(ctx::Ahorn.Cairo.CairoContext, entity::Maple.CrumbleWallOnRumble, room::Maple.Room) = Ahorn.drawTileEntity(ctx, room, entity)

end