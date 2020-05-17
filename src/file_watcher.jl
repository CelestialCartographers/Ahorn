module FileWatcher

using FileWatching

const watchedFolders = Set{String}()

basePath = "."

function getFilesRecursively(path::String)
    files = String[]
    folders = String[]

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

    return files, folders
end

# Returns all added/updated filenames since last call
# This is good enough for us, removed files don't need to be handled
function processWatchEvents(basePath::String, recursive::Bool=true, timeout::Number=0.0)
    if !(basePath in watchedFolders)
        watch_folder(basePath, timeout)
        push!(watchedFolders, basePath)
    end

    addedFiles = Set{String}()
    removedFolders = Set{String}()

    for path in watchedFolders
        # TODO - Check for better way for unwatching
        if !ispath(path)
            unwatch_folder(path)
            push!(removedFolders, path)

            continue
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
                            watch_folder(folder, timeout)
                            push!(watchedFolders, folder)
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

function initFileWatcher(celesteDir::String)
    global basePath = celesteDir

    # Call once to start watching
    watchAllFoldersRecursively(basePath)
    processWatchEvents(basePath)
end

end