module SoundSource

using ..Ahorn, Maple

const placements = Ahorn.PlacementDict(
    "Sound Source" => Ahorn.EntityPlacement(
        Maple.SoundSource
    )
)

function Ahorn.selection(entity::Maple.SoundSource)
    x, y = Ahorn.position(entity)

    return Ahorn.Rectangle(x - 12, y - 12, 24, 24)
end

Ahorn.editingOptions(entity::Maple.SoundSource) = Dict{String, Any}(
    "sound" => EnvironmentSounds.sounds
)

Ahorn.render(ctx::Ahorn.Cairo.CairoContext, entity::Maple.SoundSource, room::Maple.Room) = Ahorn.drawImage(ctx, Ahorn.Assets.speaker, -12, -12)

end