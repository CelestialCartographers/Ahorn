module CoreMessage

using ..Ahorn, Maple

# Render both vanilla and everest Core Messages, but only allow placement of Everest version as it allows custom dialog
const placements = Ahorn.PlacementDict(
    "Core Message (Everest)" => Ahorn.EntityPlacement(
        Maple.EverestCoreMessage
    )
)

coreMessageUnion = Union{Maple.EverestCoreMessage, Maple.CoreMessage}

function Ahorn.selection(entity::coreMessageUnion)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - 12, y - 12, 24, 24)
end

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::coreMessageUnion, room::Maple.Room) = Ahorn.drawImage(ctx, Ahorn.Assets.speechBubble, -12, -12)

end