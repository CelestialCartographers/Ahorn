module MetadataWindow

using Gtk, Gtk.ShortNames, Gtk.GConstants
using ..Ahorn, Maple

metadataWindow = nothing

metaDropdownOptions = Dict{String, Any}(
    "IntroType" => Maple.intro_types,
    "ColorGrade" => Maple.color_grades,
    "CoreMode" => Maple.core_modes,
    "CassetteSong" => sort(collect(values(Maple.CassetteSongs.songs))),
    "Wipe" => Maple.wipe_names
)

modeDropdownOptions = Dict{String, Any}(
    "Inventory" => Maple.inventories,
    "StartLevel" => String[]
)

metaFieldOrder = String[
    "Name", "SID", "Icon",
    "CompleteScreenName", "CassetteCheckpointIndex",
    "CassetteNoteColor", "CassetteSong",
    "TitleBaseColor", "TitleAccentColor",
    "TitleTextColor", "IntroType",
    "ColorGrade", "Wipe",
    "DarknessAlpha", "BloomBase", "BloomStrength",
    "Jumpthru", "CoreMode",
    "ForegroundTiles", "BackgroundTiles", "AnimatedTiles",
    "Portraits", "Sprites"
]

modeFieldOrder = String[]

function getOptions(data::Dict{String, Any}, dropdownOptions::Dict{String, Any}, langdata::Ahorn.LangData)
    res = Ahorn.Form.Option[]

    names = get(langdata, :names)
    tooltips = get(langdata, :tooltips)

    for (attr, value) in data
        # Due to the way Metadata is structured we don't want to generate an option for Dicts
        if isa(value, Dict)
            continue
        end

        sattr = Symbol(attr)
        keyOptions = get(dropdownOptions, attr, nothing)
        displayName = haskey(names, sattr) ? names[sattr] : Ahorn.humanizeVariableName(attr)
        tooltip = Ahorn.expandTooltipText(get(tooltips, sattr, ""))

        push!(res, Ahorn.Form.suggestOption(displayName, value, tooltip=tooltip, dataName=attr, choices=keyOptions, editable=true))
    end

    return res
end

function writeIfExists!(data::Dict{K, V}, key::K, value::V) where {K, V}
    if value !== nothing && !isempty(value)
        data[key] = value

    else
        # Delete the key to make sure any old values are cleared
        delete!(data, key)
    end
end

function addKeyIfAbsent!(data::Dict{K, V}, key::K) where {K, V}
    if !haskey(data, key)
        data[key] = Dict{K, V}()
    end
end

function deleteKeyIfEmpty!(data::Dict{K, V}, key::K) where {K, V}
    if haskey(data, key) && isempty(data[key])
        delete!(data, key)
    end
end

function createWindow()
    targetSide = Ahorn.loadedState.side

    displayCustomValues = get(Ahorn.debug.config, "DISPLAY_ALL_META_ATTRIBUTES", false)

    # Fill in possible start room values manually
    modeDropdownOptions["StartLevel"] = String[room.name for room in targetSide.map.rooms]

    langdata = get(Ahorn.langdata, :meta_window)

    metaLangdata = get(langdata, :meta)
    metaData = merge(Maple.default_meta, get(Dict{String, Any}, targetSide.data, "meta"))

    modeLangdata = get(langdata, :mode)
    modeData = merge(Maple.default_mode, get(Dict{String, Any}, metaData, "mode"))

    if !displayCustomValues
        filter!(p -> haskey(Maple.default_meta, p.first), metaData)
        filter!(p -> haskey(Maple.default_mode, p.first), modeData)
    end

    modeOptions = getOptions(modeData, modeDropdownOptions, modeLangdata)
    modeSection = Ahorn.Form.Section("Mode", modeOptions, dataName="mode", fieldOrder=modeFieldOrder)

    metaOptions = getOptions(metaData, metaDropdownOptions, metaLangdata)
    metaSection = Ahorn.Form.Section("Meta", metaOptions, dataName="meta", fieldOrder=metaFieldOrder)

    sections = Ahorn.Form.Section[
        metaSection, modeSection
    ]

    function callback(data::Dict{String, Dict{String, Any}})
        addKeyIfAbsent!(targetSide.data, "meta")
        addKeyIfAbsent!(targetSide.data["meta"], "mode")

        for (attr, value) in data["meta"]
            writeIfExists!(targetSide.data["meta"], attr, value)
        end

        for (attr, value) in data["mode"]
            writeIfExists!(targetSide.data["meta"]["mode"], attr, value)
        end

        deleteKeyIfEmpty!(targetSide.data["meta"], "mode")
        deleteKeyIfEmpty!(targetSide.data, "meta")

        name = get(data["meta"], "Name", targetSide.map.package)
        GAccessor.title(Ahorn.window, "$(Ahorn.baseTitle) - $name")
    end

    metadataWindow = Ahorn.Form.createFormWindow("$(Ahorn.baseTitle) - Configure Metadata", sections, callback=callback)

    return metadataWindow
end

function configureMetadata(widget::Ahorn.MenuItemsTypes=MenuItem())
    if Ahorn.loadedState.side != nothing
        if metadataWindow !== nothing
            Gtk.destroy(metadataWindow)
        end

        try
            global metadataWindow = createWindow()

        catch e
            println(Base.stderr, e)
            println.(Ref(Base.stderr), stacktrace())
            println(Base.stderr, "---")
        end

        showall(metadataWindow)
    end
end

end