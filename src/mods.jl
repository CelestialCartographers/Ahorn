zipFilesSupported = true
try
    using ZipFile

catch e
    # Module not installed, not vital for the program
    # Pkg2 bug, this package might not be installed
    
    zipFilesSupported = false
end

function getAhornModDirs()
    if !get(config, "load_plugins_ahorn", true)
        return String[]
    end

    modsPath = joinpath(storageDirectory, "plugins")
    targetFolders = String[]

    if isdir(modsPath)
        for fn in readdir(modsPath)
            if isdir(joinpath(modsPath, fn))
                push!(targetFolders, joinpath(modsPath, fn))
            end
        end
    end

    return targetFolders
end

function getAhornModZips()
    if !zipFilesSupported || !get(config, "load_plugins_ahorn_zip", true)
        return String[]
    end

    modsPath = joinpath(storageDirectory, "plugins")
    targetFolders = String[]

    if isdir(modsPath)
        for fn in readdir(modsPath)
            if isfile(joinpath(modsPath, fn)) && hasExt(fn, ".zip")
                push!(targetZips, joinpath(modsPath, fn))
            end
        end
    end

    return targetFolders
end

function getCelesteModDirs()
    if !get(config, "load_plugins_celeste", true)
        return String[]
    end

    celesteDir = get(config, "celeste_dir", "")
    modsPath = joinpath(celesteDir, "Mods")

    targetFolders = String[]

    if isdir(modsPath)
        for fn in readdir(modsPath)
            if isdir(joinpath(modsPath, fn))
                push!(targetFolders, joinpath(modsPath, fn))
            end
        end
    end

    return targetFolders
end

function getCelesteModZips()
    if !zipFilesSupported || !get(config, "load_plugins_celeste_zip", true)
        return String[]
    end

    celesteDir = get(config, "celeste_dir", "")
    modsPath = joinpath(celesteDir, "Mods")

    targetZips = String[]

    if isdir(modsPath)
        for fn in readdir(modsPath)
            if isfile(joinpath(modsPath, fn)) && hasExt(fn, ".zip")
                push!(targetZips, joinpath(modsPath, fn))
            end
        end
    end

    return targetZips
end

function findExternalSprite(resource::String)
    targetFolders = getCelesteModDirs()
    targetZips = getCelesteModZips()
    gameplayPath = joinpath("Graphics", "Atlases", "Gameplay")

    for target in targetFolders
        fn = joinpath(target, gameplayPath, splitext(resource)[1] * ".png")
        if isfile(fn)
            return fn
        end
    end

    for target in targetZips
        fn = joinpath(gameplayPath, splitext(resource)[1] * ".png")
        zipfh = ZipFile.Reader(target)

        for file in zipfh.files
            if file.name == fn
                return target
            end
        end

        close(zipfh)
    end
end

function findExternalSprites()
    res = Tuple{String, String}[]
    
    targetFolders = getCelesteModDirs()
    targetZips = getCelesteModZips()
    gameplayPath = joinpath("Graphics", "Atlases", "Gameplay")

    for target in targetFolders
        path = joinpath(target, gameplayPath)
        if isdir(path)
            for (root, dir, files) in walkdir(path)
                for file in files
                    if hasExt(file, ".png")
                        rawpath = joinpath(root, file)
                        push!(res, (relpath(rawpath, path), rawpath))
                    end
                end
            end
        end
    end

    for target in targetZips
        zipfh = ZipFile.Reader(target)

        for file in zipfh.files
            name = file.name

            if startswith(name, gameplayPath)
                if hasExt(name, ".png")
                    push!(res, (relpath(name, gameplayPath), target))
                end
            end
        end

        close(zipfh)
    end
    
    return res
end

function findExternalModules(args::String...)
    res = String[]

    targetFolders = vcat(
        joinpath.(getCelesteModDirs(), "Ahorn"),
        getAhornModDirs()
    )

    for folder in targetFolders
        path = joinpath(folder, args...)
        if isdir(path)
            for file in readdir(path)
                if hasExt(file, ".jl")
                    push!(res, joinpath(path, file))
                end
            end
        end
    end

    return res
end

function loadExternalModules!(loadedModules::Dict{String, Module}, loadedNames::Array{String, 1}, args::String...)
    # ZipFile uses linux paths 
    path = joinpath("Ahorn", args...)
    path = replace(path, "\\", "/")

    targets = vcat(
        getCelesteModZips(),
        getAhornModZips()
    )

    for target in targets
        zipfh = ZipFile.Reader(target)

        for file in zipfh.files
            name = file.name

            if startswith(name, path) && file.uncompressedsize > 0
                # Add .from_zip to the filename
                # Prevents hotswaping from trying to access invalid file
                fakeFn = name * ".from_zip"

                try
                    loadedModules[fakeFn] = eval(parse(readstring(file)))

                    if !(fakeFn in loadedNames)
                        push!(loadedNames, fakeFn)
                    end

                catch
                    println("! Failed to load \"$name\" from \"$target\"")
                end
            end
        end

        close(zipfh)
    end
end