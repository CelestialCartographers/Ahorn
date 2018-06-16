function getModDirs()
    celesteDir = config["celeste_dir"]
    modsPath = joinpath(celesteDir, "Mods")
    modcontentPath = joinpath(celesteDir, "ModContent")

    targetFolders = String[]

    if isdir(modsPath)
        for fn in readdir(modsPath)
            if isdir(joinpath(modsPath, fn))
                push!(targetFolders, joinpath(modsPath, fn))
            end
        end
    end

    push!(targetFolders, modcontentPath)

    return targetFolders
end

function findExternalSprites()
    res = Tuple{String, String}[]
    
    targetFolders = getModDirs()
    gameplayPath = joinpath("Graphics", "Atlases", "Gameplay")

    for target in targetFolders
        path = joinpath(target, gameplayPath)
        if isdir(path)
            for (root, dir, files) in walkdir(path)
                for file in files
                    if splitext(file)[2] == ".png"
                        rawpath = joinpath(root, file)
                        push!(res, (relpath(rawpath, path), rawpath))
                    end
                end
            end
        end
    end

    return res
end

function findExternalModules(args::String...)
    res = String[]
    targetFolders = getModDirs()
    
    for folder in targetFolders
        path = joinpath(folder, args...)
        if isdir(path)
            for file in readdir(path)
                if splitext(file)[2] == ".jl"
                    push!(res, joinpath(path, file))
                end
            end
        end
    end

    return res
end