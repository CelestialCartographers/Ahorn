module PackageHelper

using JSON

export pkgpath, depotpath
export pkghash, pkghash_tree, pkghash_short
export latesthash, latesthash_tree

function print_error()
    println(Base.stderr, "Update check failed")
    for (exc, bt) in Base.catch_stack()
        showerror(Base.stderr, exc, bt)
        println(Base.stderr, "")
    end
end

pkgpath(pkg) = pathof(pkg) |> dirname |> dirname
depotpath(pkg) = pkgpath(pkg) |> dirname |> dirname |> dirname

function pkghash_tree()
    try
        ctx = Pkg.Types.Context()
        return string(ctx.env.manifest[ctx.env.project.deps["Ahorn"]].tree_hash)
    catch e
        return nothing
    end
end

function pkghash()
    try
        clonespath = joinpath(depotpath(Ahorn), "clones")
        for clone in readdir(clonespath)
            clonepath = joinpath(clonespath, clone)
            configpath= joinpath(clonepath, "config")
            if isfile(configpath)
                config = read(configpath, String)
                if !occursin("url = https://github.com/CelestialCartographers/Ahorn.git", config)
                    continue
                end
                headpath = joinpath(clonepath, "FETCH_HEAD")
                head = read(headpath, String)
                hash = match(r"([0-9a-f]+)[^\n]+'master'", head).captures[1]
                return hash
            end
        end
    catch e
        return nothing
    end

    return nothing
end

function pkghash_short()
    h = pkghash()
    if h !== nothing
       h = "$(h[1:7]) (git)"
    else
        h = pkghash_tree()
        if h !== nothing
            h = "$(h[1:7]) (pkg)"
        end
    end
    return h
end

const apiurl = "https://api.github.com/repos/CelestialCartographers/Ahorn/commits/master"

function latesthash()
    try
        path = download(apiurl)
        json = open(JSON.parse, path)
        return json["sha"]
    catch e
        print_error()
        return nothing
    end
end

function latesthash_tree()
    try
        path = download(apiurl)
        json = open(JSON.parse, path)
        return json["commit"]["tree"]["sha"]
    catch e
        print_error()
        return nothing
    end
end

end