
if !isdefined(:TEST_RUNNING)
    try
        Pkg.installed("Maple")

    catch err
        println("Maple is not installed - Please run `julia install_ahorn.jl` to install all necessary dependencies.")
        exit()
    end
end

println("""
If this is the first time running Ahorn this might take a while.
The window might stay blank for a long time, this is normal as packages are precompiling in the background.
""")

# Fixes theme issues on Windows
if is_windows()
    ENV["GTK_THEME"] = get(ENV, "GTK_THEME", "win32")
    ENV["GTK_CSD"] = get(ENV, "GTK_CSD", "0")
end

using Ahorn

Ahorn.displayMainWindow()