set PATH=%PATH%;%LocalAppData%/julia-0.6.2/bin/
set PATH=%PATH%;%LocalAppData%/julia-0.6.3/bin/
julia -e "run(`julia $(joinpath(Pkg.dir(\"Ahorn\"), \"src\", \"run_ahorn.jl\"))`)"
exit