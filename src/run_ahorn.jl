println("""
If this is the first time running Ahorn this might take a while.
The window might stay blank for a long time, this is normal as packages are precompiling in the background.
""")
include(joinpath(Pkg.dir("Ahorn"), "src", "main.jl"))