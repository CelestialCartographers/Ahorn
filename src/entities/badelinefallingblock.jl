module BadelineFallingBlock

# Just a FallingBlock with some preset data
# No need to handle anything but placement
placements = Dict{String, Main.EntityPlacement}(
    "Badeline Boss Falling Block" => Main.EntityPlacement(
        Main.Maple.BadelineFallingBlock,
        "rectangle",
    )
)

end