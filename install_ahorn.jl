# Ahorn's installation script. Connects to the internet using Pkg3 to install it.

if VERSION < v"1.1"
    println("""Ahorn, and thus this installer, require Julia version 1.1 or later to run.
    The version you installed is $VERSION. Please update to a more recent version.
    Press Enter to quit the installer.""")
    readline()
    exit()
end

using Pkg

install_or_update(url::String, pkg::String) = try 
    if Pkg.installed()[pkg] !== nothing
        println("Updating $pkg...")
        Pkg.update(pkg)
    end
catch err
    println("Installing $pkg...")
    Pkg.add(PackageSpec(url=url))
end

if Sys.iswindows()
    installpath = joinpath(ENV["LOCALAPPDATA"], "Ahorn", "env")
else
    installpath = joinpath(get(ENV, "XDG_CONFIG_HOME", joinpath(get(ENV, "HOME", ""), ".config")) , "Ahorn", "env")
end

println("""
======================
Hey, thanks for giving Ahorn a try! Ahorn is currently still in a very early state. If you find bugs, please report them!
======================
""")

println("This installer is going to install or update Maple and Ahorn via the package manager as well as create a file in the same directory as this installer file, are you okay with that? [y/N]")

if !occursin(r"^[Yy]", readline())
    println("Exiting installer.")
    exit()
end

println("""

======================
The installer will now download and install required dependencies as well as the program itself. This will likely take a few minutes, so grab yourself a glass of juice while you wait.
We will tell you when the installation process is done, any warnings (not errors) in the console are fine and can be ignored.
======================
""")

mkpath(installpath)

println("Environment path: " * installpath)

Pkg.activate(installpath)

install_or_update("https://github.com/CelestialCartographers/Maple.git", "Maple")
install_or_update("https://github.com/CelestialCartographers/Ahorn.git", "Ahorn")

println("""

======================
Precompiling a few dependencies. This may take a while, so get yourself some cheese and a cup of fennel tea.
======================
""")

sleep(1)
Pkg.API.precompile()
import Ahorn

pkgdir = normpath(joinpath(dirname(pathof(Ahorn)), ".."))
println("Package path: " * pkgdir)

launchpath = nothing
if Sys.iswindows()
    launchpath = joinpath(@__DIR__, "ahorn.bat")
    cp(joinpath(pkgdir, "ahorn.bat"), launchpath, force=true)
else
    #symlink(joinpath(pkgdir, "src", "run_ahorn.jl"), joinpath(@__DIR__, "ahorn.jl"))
    launchpath = joinpath(@__DIR__, "ahorn.sh")
    if isfile(launchpath)
        println("Removing old ahorn.sh...")
        rm(launchpath)
    end
    #symlink(joinpath(pkgdir, "ahorn"), launchpath)
    cp(joinpath(pkgdir, "ahorn"), launchpath, force=true)
end

if Sys.iswindows()
    println("""

Done! Ahorn should be installed now. Run $launchpath to launch it.
Note that it will take quite a while to launch the first time as its dependencies compile, so please be patient.

Thanks for giving Ahorn a try!

Press Enter to quit the installer.
""")
else
    println("""

Done! Ahorn should be installed now. If Julia is in your path, just run $launchpath to launch it.
Note that it will take quite a while to launch the first time as its dependencies compile, so please be patient.

Thanks for giving Ahorn a try!

Press Enter to quit the installer.
""")
end
readline()