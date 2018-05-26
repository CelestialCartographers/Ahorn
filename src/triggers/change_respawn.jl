module ChangeRespawn

placements = Dict{String, Main.EntityPlacement}(
    "Change Respawn" => Main.EntityPlacement(
        Main.Maple.ChangeRespawnTrigger,
        "rectangle"
    )
)

end