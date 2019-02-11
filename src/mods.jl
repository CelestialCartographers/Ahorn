using ZipFile

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
    if !get(config, "load_plugins_ahorn_zip", true)
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

function getModRoot(fn::String)
    celesteDir = get(config, "celeste_dir", "")
    modsPath = normpath(joinpath(celesteDir, "Mods"))

    path = normpath(fn)

    while true
        parent = dirname(path)

        if parent == modsPath
            if isdir(path)
                return true, path

            else
                return true, parent
            end
        end

        if path == parent
            return false, ""
        end

        path = parent
    end
end

function getCelesteModZips()
    if !get(config, "load_plugins_celeste_zip", true)
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

function findExternalSprite(resource::String, atlas::String="Gameplay")
    targetFolders = getCelesteModDirs()
    targetZips = getCelesteModZips()
    atlasPath = joinpath("Graphics", "Atlases", atlas)

    for target in targetFolders
        fn = joinpath(target, atlasPath, resource * ".png")
        if isfile(fn)
            return fn
        end
    end

    # ZipFile uses unix paths
    gameplayUnixPath = replace(atlasPath, "\\" => "/")

    for target in targetZips
        fn = gameplayUnixPath * "/" * resource * ".png"
        zipfh = ZipFile.Reader(target)

        for file in zipfh.files
            if file.name == fn
                return target
            end
        end

        close(zipfh)
    end
end

warnedFilenames = Set{String}()

function warnBadExtensions(fixable::Array{String, 1}, nonFixable::Array{String, 1}, correctExt::String)
    res = false

    fixable = String[fn for fn in fixable if !(fn in warnedFilenames)]
    nonFixable = String[fn for fn in nonFixable if !(fn in warnedFilenames)]

    if !isempty(fixable)
        fixableCount = length(fixable)
        plural = fixableCount == 1 ? "" : "s"
        dialogText = "You have $fixableCount image$plural with bad extension$plural.\n" *
            "These are not loadable by Celeste (Everest).\n" * 
            "Do you want to rename them?\n\n" *
            join(fixable, "\n")
        confirmed = ask_dialog(dialogText, Ahorn.window)
        res = confirmed

        if confirmed
            for fn in fixable
                path, ext = splitext(fn)
                out = path * correctExt
                tmp = out * ".tmp"

                # Workaround for Windows...
                mv(fn, tmp)
                mv(tmp, out)
            end

        else
            push!(warnedFilenames, fixable...)
        end
    end

    if !isempty(nonFixable)
        nonFixableCount = length(nonFixable)
        plural = nonFixableCount == 1 ? "" : "s"
        dialogText = "You have $nonFixableCount file$plural with bad extension$plural that cannot be automatically fixed.\n" *
            "These are not loadable by Celeste (Everest).\n" * 
            "Please rename the file$plural manually with the proper extension '$correctExt' or contact the mod maker.\n\n" * 
            join(nonFixable, "\n")
        info_dialog(dialogText, Ahorn.window)

        push!(warnedFilenames, nonFixable...)
    end

    return res
end

function findExternalSprites()
    warnOnBadExts = get(config, "prompt_bad_resource_exts", true)
    res = Tuple{String, String, String}[]

    folderFileBadExt = String[]
    zipFileBadExt = String[]
    
    targetFolders = getCelesteModDirs()
    targetZips = getCelesteModZips()
    atlasesPath = joinpath("Graphics", "Atlases")

    for target in targetFolders
        atlasPath = joinpath(target, atlasesPath)

        if !isdir(atlasPath)
            continue
        end

        for atlas in readdir(atlasPath)
            path = joinpath(atlasPath, atlas)

            if isdir(path)
                for (root, dir, files) in walkdir(path)
                    for file in files
                        if hasExt(file, ".png")
                            if !hasExt(file, ".png", false)
                                # Case sensitive check for warnings
                                push!(folderFileBadExt, joinpath(root, file))
                            end

                            rawpath = joinpath(root, file)
                            push!(res, (relpath(rawpath, path), rawpath, atlas))
                        end
                    end
                end
            end
        end
    end

    # ZipFile uses unix paths
    atlasesUnixPath = replace(atlasesPath, "\\" => "/")

    for target in targetZips
        try
            zipfh = ZipFile.Reader(target)

            for file in zipfh.files
                name = file.name

                if startswith(name, atlasesUnixPath)
                    if hasExt(name, ".png")
                        if !hasExt(name, ".png", false)
                            # Case sensitive check for warnings
                            push!(zipFileBadExt, joinpath(target, name))
                        end

                        # This should be safe, but probably not...
                        atlas = split(name, "/")[3]

                        push!(res, (relpath(name, joinpath(atlasesPath, atlas)), target, atlas))
                    end
                end
            end

            close(zipfh)

        catch e
            println(Base.stderr, "Failed to load zip file '$target'")
            println(Base.stderr, e)
        end
    end

    if warnOnBadExts
        confirmed = warnBadExtensions(folderFileBadExt, zipFileBadExt, ".png")

        if confirmed
            return findExternalSprites()
        end
    end
    
    return res
end

function loadLangdata()
    targetFolders = joinpath.(getCelesteModDirs(), "Ahorn")
    targetZips = getCelesteModZips()

    lang = get(config, "language", "en_gb")
    internalFilename = abspath("../lang/$lang.lang")

    res = parseLangfile(String(read(internalFilename)))

    for folder in targetFolders
        fn = joinpath(folder, "lang", "$(lang).lang")
        if ispath(fn)
            content = String(read(fn))
            parseLangfile(content, init=res)
        end
    end

    for fn in targetZips
        zipfh = ZipFile.Reader(fn)
        
        for file in zipfh.files
            name = file.name
            path, fnext = splitext(name)

            if path == "Ahorn/lang/$(lang)" && hasExt(name, ".lang")
                content = String(read(file))
                parseLangfile(content, init=res)
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
    # ZipFile uses unix paths 
    path = joinpath("Ahorn", args...)
    path = replace(path, "\\" => "/")

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
                    content = String(read(file))
                    loadedModules[fakeFn] = eval(Meta.parse(content))

                    if !(fakeFn in loadedNames)
                        push!(loadedNames, fakeFn)
                    end

                catch e
                    println(Base.stderr, "! Failed to load \"$name\" from \"$target\"")
                    println(Base.stderr, e)
                end
            end
        end

        close(zipfh)
    end
end