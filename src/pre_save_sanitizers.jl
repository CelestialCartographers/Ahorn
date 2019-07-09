module PreSaveSanitizers

using ..Ahorn, Maple
using Gtk, Gtk.ShortNames

function sortRoomNames(side::Maple.Side, config::Ahorn.Config)
    map = side.map
    sortRoomNames = get(config, "sort_rooms_on_save", true)

    if sortRoomNames
        sort!(map.rooms, by=r -> r.name)
        Ahorn.updateTreeView!(Ahorn.roomList, Ahorn.getTreeData(map), row -> row[1] == Ahorn.loadedState.roomName, updateByReplacement=true)
    end
end

function warnMissingDecals(side::Maple.Side, config::Ahorn.Config)
    map = side.map
    warnMissing = get(config, "warn_missing_decals_on_save", true)

    if warnMissing
        Ahorn.loadExternalSprites!()
        textures = Ahorn.spritesToDecalTextures(Ahorn.getAtlas("Gameplay"))

        missing = Tuple{Maple.Room, Array{Maple.Decal, 1}, Maple.Decal}[]

        for room in map.rooms
            for decals in [room.fgDecals, room.bgDecals]
                for decal in decals
                    texture = Ahorn.fixTexturePath(decal.texture)
                    if !(splitext(texture)[1] in textures || texture in textures)
                        push!(missing, (room, decals, decal))
                    end
                end
            end
        end

        missingCount = length(missing)
        plural = missingCount == 1 ? "" : "s"

        if missingCount > 0
            uniqueNames = unique(String[decal.texture for (room, decals, decal) in missing])

            dialogText = "You have $missingCount decal$plural with no longer existing texture$plural.\n" *
                "These can potentially crash Celeste when their room is loaded.\n" * 
                "Do you want to automatically delete these decals?\n\n" * 
                join(uniqueNames, "\n")
            confirmed = ask_dialog(dialogText, Ahorn.window)
        
            if confirmed
                Ahorn.History.addSnapshot!(Ahorn.History.MapSnapshot("Deleting missing decals", map))

                for (room, decals, decal) in missing
                    filter!(d -> !(d.texture in uniqueNames), decals)
                end
            end
        end
    end
end

function warnDuplicateIds(side::Maple.Side, config::Ahorn.Config)
    map = side.map
    warnDuplicate = get(config, "warn_duplicate_entity_ids_on_save", true)

    if warnDuplicate
        idGroupDict = Ahorn.EntityIds.groupByIds(map)
        duplicateIndices = Int[]
        duplicateCount = 0

        for (id, targets) in idGroupDict
            if length(targets) > 1 
                push!(duplicateIndices, id)
                duplicateCount += length(targets)
            end
        end

        if duplicateCount > 0
            plural1 = duplicateCount == 1 ? "" : "s"
            plural2 = duplicateCount == 1 ? "y" : "ies"
            dialogText = "You have $duplicateCount entit$plural2/trigger$plural1 with duplicate ID$plural1.\n" *
                "This can cause entities or triggers to get disabled when they shouldn't be, or other weird behaviour in Celeste.\n" * 
                "Do you want to automatically reassign IDs?"
            confirmed = ask_dialog(dialogText, Ahorn.window)

            if confirmed
                Ahorn.History.addSnapshot!(Ahorn.History.MapSnapshot("Reassigning entity/trigger IDs", map))

                success, reassigned = Ahorn.EntityIds.attemptIdFixing(map, idGroupDict)

                if !success
                    dialogText = "Some entities/triggers were not safe to reassign IDs to.\n" *
                        "Do you want to reassign IDs anyways? This might cause entities that depend on raw IDs to need reconfiguring."
                    confirmed = ask_dialog(dialogText, Ahorn.window)

                    if confirmed
                        Ahorn.EntityIds.attemptIdFixing(map, idGroupDict, true)
                    end
                end
            end
        end
    end
end

end