module CutsceneNode

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Cutscene Node" => Ahorn.EntityPlacement(
        Maple.CutsceneNode
    )
)

function Ahorn.selection(entity::Maple.CutsceneNode)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle[Ahorn.Rectangle(x - 12, y - 12, 24, 24)]
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.CutsceneNode, room::Maple.Room) = Ahorn.drawImage(ctx, Ahorn.Assets.cutsceneNode, -12, -12)

end