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

println("This installer is going to install or update Maple and Ahorn via the package manager as well as create two symbolic links in your current directory, are you okay with that? [y/N]")
confirmation = readline()

if !ismatch(r"^[Yy]", confirmation)
    println("Exiting installer.")
    exit()
end

println("""
The installer will now download and install required dependencies as well as the program itself. This will likely take a few minutes, so grab yourself a glass of juice while you wait.
""")

install_or_update("https://github.com/CelestialCartographers/Maple.git", "Maple")
install_or_update("https://github.com/CelestialCartographers/Ahorn.git", "Ahorn")

symlink(joinpath(Pkg.dir("Ahorn"), "src", "run_ahorn.jl"), "ahorn.jl")

if is_windows()
    #symlink(joinpath(Pkg.dir("Ahorn"), "ahorn.bat"), "ahorn.bat")
else
    symlink(joinpath(Pkg.dir("Ahorn"), "ahorn"), "ahorn.sh")
end

println("""
Done! Ahorn should be installed now. Run ahorn.jl with Julia to launch it$(!is_windows() ? ", or, if Julia is in your path, just run ./ahorn" : "").
Note that it will take quite a while to launch the first time as its dependencies compile, so please be patient.

Thanks for giving Ahorn a try!
""")