module Backup

using ..Ahorn, Maple
using Gtk, Gtk.ShortNames
using Dates

const timestampFormat = "YYYY-mm-dd HH-MM-SS"

backupTimer = nothing

function getTimestamp()
    return Dates.format(Dates.now(), timestampFormat)
end

function getFilename(side::Side)
    return joinpath(getSideName(side), getTimestamp() * ".bin")
end

function getBackupFilename(side::Side)
    return joinpath(getSideName(side), "LATEST.bin")
end

function pruneBackups(folder::String, side::Side, keep::Int=10)
    files = Tuple{String, DateTime}[]
    targetFolder = joinpath(folder, getSideName(side))

    for fn in readdir(targetFolder)
        try
            timestamp = DateTime(splitext(fn)[1], timestampFormat)
            push!(files, (fn, timestamp))

        catch ArgumentError
            # Ignore, file with bad format
            # Could be "LATEST" file or user manual backups
        end
    end

    sort!(files, rev=true, by=v -> v[2])
    deleting = getindex.(files[keep + 1:end], 1)

    rm.(joinpath.(Ref(targetFolder), deleting))
end

function backup(side::Side, prune::Bool=true)
    backupFolder = get(Ahorn.config, "backup_directory", joinpath(Ahorn.storageDirectory, "Backups"))
    keep = get(Ahorn.config, "backup_maximum_files", 10)

    filename = getFilename(side)
    latestFilename = getBackupFilename(side)

    outFilename = joinpath(backupFolder, filename)
    outLatestFilename = joinpath(backupFolder, latestFilename)

    mkpath(dirname(outFilename))

    encodeSide(side, outFilename)
    encodeSide(side, outLatestFilename)

    if prune
        pruneBackups(backupFolder, side, keep)
    end
end

function startAutomaticBackup()
    backupRate = get(Ahorn.config, "backup_rate", 60)

    global backupTimer = Timer(0, interval=backupRate) do timer
        side = Ahorn.loadedState.side

        @Ahorn.catchall begin
            if side !== nothing
                backup(side)
            end
        end
    end
end

function openBackupDialog()
    side = Ahorn.loadedState.side
    backupFolder = get(Ahorn.config, "backup_directory", joinpath(Ahorn.storageDirectory, "Backups"))

    if side === nothing
        Ahorn.showFileOpenDialog(MenuItem(), backupFolder)
        Ahorn.loadedState.filename = ""
        Ahorn.persistence["files_lastfile"] = ""

    else
        latestFilename = Ahorn.loadedState.filename
        latestBackupFilename = getBackupFilename(side)

        # The latest filename may also be in another folder, make sure we get the right folder
        Ahorn.showFileOpenDialog(MenuItem(), dirname(joinpath(backupFolder, latestBackupFilename)))
        Ahorn.loadedState.filename = latestFilename
        Ahorn.persistence["files_lastfile"] = latestFilename
    end
end

function initBackup(persistence::Ahorn.Config)
    active = get(Ahorn.config, "backup_enabled", true)
    showDialog = get(Ahorn.config, "backup_dialog_enabled", true)

    if active && showDialog && get(persistence, "currently_running", false)
        @async begin
            if ask_dialog("Ahorn did not shut down properly.\nDo you want to restore from automatic backup?", Ahorn.window)
                openBackupDialog()
            end

            startAutomaticBackup()
        end

    else
        startAutomaticBackup()
    end

    persistence["currently_running"] = true
    Ahorn.saveConfig(persistence, true)
end

end