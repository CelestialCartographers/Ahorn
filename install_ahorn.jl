install_or_update(url::String, pkg::String) = try 
    if Pkg.installed(pkg) !== nothing
        println("Updating $pkg...")
        Pkg.update(pkg)
    end
catch err
    println("Installing $pkg...")
    Pkg.clone(url, pkg)
end

println("""
======================
Hey, thanks for giving Ahorn a try! Ahorn is currently still in a very early state. If you find bugs, please report them!
======================
""")

println("This installer is going to install or update Maple and Ahorn via the package manager as well as create two symbolic links in the same directory as this installer file, are you okay with that? [y/N]")

if !ismatch(r"^[Yy]", readline())
    println("Exiting installer.")
    exit()
end

println("""
This installer can install the HTTP.jl library to enable integration with the Everest Mod Loader. If Everest is installed in Celeste and running in debug mode, you will be able to Ctrl+Shift+Click on a room in Ahorn while the game is running to teleport there in game.
However, on older versions of Windows (e.g. Windows 7), installing HTTP might fail unless a certain update is installed.
If you want to install it later, just run Pkg.add("HTTP") in Julia.
Would you like to install the HTTP library? [y/N]""")


installHTTP = ismatch(r"^[Yy]", readline())

println("""
The installer will now download and install required dependencies as well as the program itself. This will likely take a few minutes, so grab yourself a glass of juice while you wait.
""")

install_or_update("https://github.com/CelestialCartographers/Maple.git", "Maple")
install_or_update("https://github.com/CelestialCartographers/Ahorn.git", "Ahorn")

if installHTTP
    Pkg.add("HTTP")
end

if is_windows()
    #symlink(joinpath(Pkg.dir("Ahorn"), "ahorn.bat"), joinpath(@__DIR__, "ahorn.bat")
else
    symlink(joinpath(Pkg.dir("Ahorn"), "src", "run_ahorn.jl"), joinpath(@__DIR__, "ahorn.jl"))
    symlink(joinpath(Pkg.dir("Ahorn"), "ahorn"), joinpath(@__DIR__, "ahorn.sh"))
end

println("""

======================
Precompiling a few dependencies. This may take a while, so get yourself some cheese and a cup of fennel tea.
======================
""")
using Maple, Cairo, Gtk, Images, YAML, LightXML

if is_windows()
    println("""

Done! Ahorn should be installed now. Run $(joinpath(Pkg.dir("Ahorn"), "src", "run_ahorn.jl")) with Julia to launch it.
Note that it will take quite a while to launch the first time as its dependencies compile, so please be patient.

Thanks for giving Ahorn a try!
""")
else
    println("""

Done! Ahorn should be installed now. Run ahorn.jl with Julia to launch it, or, if Julia is in your path, just run ./ahorn.
Note that it will take quite a while to launch the first time as its dependencies compile, so please be patient.

Thanks for giving Ahorn a try!
""")
end