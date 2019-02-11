materialFilterEntry = Entry(
    primary_icon_name="edit-find-symbolic",
    secondary_icon_name="edit-clear-symbolic",
    placeholder_text="Search..."
)

@guarded signal_connect(materialFilterEntry, "changed") do widget
    text = Gtk.bytestring(GAccessor.text(widget))
    lcText = lowercase(text)

    searchRawNames = get(config, "search_entities_raw_name", true)
    searchAttributes = get(config, "search_entities_attributes", true)
    searchTooltips = get(config, "search_entities_tooltips", false)
    needsPlacements = searchRawNames || searchAttributes || searchTooltips

    # TODO - This relies on layers list having raw names
    targetLayerIndex = Ahorn.getSelected(Ahorn.layersList)
    targetLayer = targetLayerIndex !== nothing ? Ahorn.layersList.data[targetLayerIndex][1] : nothing

    if targetLayer !== nothing
        Ahorn.persistence["material_search_$(targetLayer)"] = text
    end

    cache = Dict{String, Any}()
    placements = nothing

    tooltipKey = ""

    if needsPlacements
        if targetLayer == "entities"
            cache = Ahorn.entityPlacementsCache
            placements = Ahorn.entityPlacements
            tooltipKey = "entities"

        elseif targetLayer == "triggers"
            cache = Ahorn.triggerPlacementsCache
            placements = Ahorn.triggerPlacements
            tooltipKey = "triggers"
        end
    end

    for row in 1:length(materialList.data)
        visible = false

        materialName = materialList.data[row][1]
        visible = occursin(lcText, lowercase(materialName))

        if !visible && placements !== nothing && haskey(placements, materialName)
            ep = placements[materialName]
            name = isa(ep.func, DataType) ? string(ep.func.parameters[1]) : nothing
            target = get(cache, materialName, nothing)

            if name === nothing && target === nothing
                target = Ahorn.getCachedPlacement!(cache, placements, materialName)
                name = target.name
            end

            if name !== nothing
                tooltips = get(Ahorn.langdata, ["placements", tooltipKey, name, "tooltips"])
                visible |= searchRawNames && occursin(lcText, lowercase(name))

                if !visible && searchAttributes
                    data = target !== nothing ? target.data : tooltips
                    for attr in keys(data)
                        visible |= occursin(lcText, lowercase(string(attr)))
                    end
                end

                if !visible && searchTooltips
                    for value in values(tooltips)
                        visible |= occursin(lcText, lowercase(value))
                    end
                end
            end
        end

        materialList.visible[row] = visible
    end

    # Don't select anything automatically, notify tool to do so instead
    Gtk.GLib.@sigatom filterContainer!(materialList, nothing)
    Ahorn.notifyMaterialsFiltered(text)
end

@guarded signal_connect(materialFilterEntry, "icon-press") do widget, n, event
    Gtk.GLib.@sigatom GAccessor.text(widget, "")
end

function handleFilterKeyPressed(event::Gtk.GdkEventKey)
    if event.keyval == Gtk.GdkKeySyms.Escape
        unfocusFilterEntry!()

        return true

    elseif event.keyval == Gtk.GdkKeySyms.Return
        unfocusFilterEntry!()

        Gtk.GLib.@sigatom GAccessor.text(materialFilterEntry, "")

        return true
    end

    return false
end

function focusFilterEntry!(args...)
    GAccessor.focus(window, materialFilterEntry)
end

function unfocusFilterEntry!(args...)
    # Can't focus the canvas, focus something we know exists
    GAccessor.focus(window, scrollableWindowMaterialList)
end