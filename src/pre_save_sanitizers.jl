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

            dialogText = "You have $missingCount decals with no longer existing texture$plural.\n" *
                "These can potentially crash Celeste when their room is loaded.\n" * 
                "Do you want to automatically delete these decals?\n\n" * 
                join(uniqueNames, "\n")
            confirmed = ask_dialog(dialogText, Ahorn.window)
        
            if confirmed
                History.addSnapshot!(History.MapSnapshot("Deleting missing decals", map))

                for (room, decals, decal) in missing
                    filter!(d -> !(d.texture in uniqueNames), decals)
                end
            end
        end
    end
end

end