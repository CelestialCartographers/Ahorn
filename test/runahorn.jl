push!(LOAD_PATH, "$(pwd())/Maple/src") # Don't use this when this is an actuall module itself

TEST_RUNNING = true
include("$(pwd())/src/main.jl")