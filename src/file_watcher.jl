module FileWatcher

using FileWatching

const watchedFolders = Set{String}()

basePath = "."

function getFilesRecursively(path::String)
    files = String[]
    folders = String[]

    if isdir(path)
        for file in readdir(path)
            filename = joinpath(path, file)

            if isdir(filename)
                subFiles, subFolders = getFilesRecursively(filename)

                push!(folders, filename)
                append!(folders, subFolders)
                append!(files, subFiles)

            elseif isfile(filename)
                push!(files, filename)
            end
        end
    end

    return files, folders
end

function attemptToWatchFolder(path::String, timeout::Number=0.0)
    if isdir(path) && !(path in watchedFolders)
        try
            watch_folder(path, timeout)
            push!(watchedFolders, path)

        catch e
            println(Base.stderr, "Failed to watch $path")

            for (exc, bt) in Base.catch_stack()
                showerror(Base.stderr, exc, bt)
                println()
            end
        end
    end
end

# Returns all added/updated filenames since last call
# This is good enough for us, removed files don't need to be handled
function processWatchEvents(basePath::String, recursive::Bool=true, timeout::Number=0.0)
    attemptToWatchFolder(basePath, timeout)

    addedFiles = Set{String}()
    removedFolders = Set{String}()

    for path in watchedFolders
        try
            # TODO - Check for better way for unwatching
            if !ispath(path)
                unwatch_folder(path)
                push!(removedFolders, path)

                continue
            end

        catch
            # Do nothing, check again next time
        end

        while true
            relative, event = watch_folder(path, timeout)

            if event.timedout
                # No changes since last check

                break
            end

            filename = joinpath(path, relative)

            if event.changed
                # Check if file was removed or added
                # Folders add all sub files recursively
                # Watch folder as well if recursive

                if isdir(filename)
                    files, folders = getFilesRecursively(filename)

                    if recursive
                        watch_folder(filename, timeout)
                        push!(watchedFolders, filename)

                        for folder in folders
                            attemptToWatchFolder(folder, timeout)
                        end
                    end

                    union!(addedFiles, files)

                elseif isfile(filename)
                    push!(addedFiles, filename)
                end
            end
        end

        setdiff!(watchedFolders, removedFolders)
    end

    return addedFiles
end

function watchAllFoldersRecursively(basePath::String, timeout::Number=0.0)
    files, folders = getFilesRecursively(basePath)

    for folder in folders
        watch_folder(folder, timeout)
        push!(watchedFolders, folder)
    end
end

function initFileWatcher(targetPath::String)
    global basePath = targetPath

    # Call once to start watching
    watchAllFoldersRecursively(basePath)
    processWatchEvents(basePath)
end

end