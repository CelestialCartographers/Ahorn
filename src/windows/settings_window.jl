module SettingsWindow

using Gtk, Gtk.ShortNames, Gtk.GConstants
using ..Ahorn, Maple

settingsWindow = nothing

function getOptions(data::Dict{Any, Any}, dropdownOptions::Dict{String, Any}, langdata::Ahorn.LangData)
    res = Ahorn.Form.Option[]

    names = get(langdata, :names)
    tooltips = get(langdata, :tooltips)

    for (attr, value) in data
        sattr = Symbol(attr)
        keyOptions = get(dropdownOptions, attr, nothing)
        displayName = haskey(names, sattr) ? names[sattr] : Ahorn.humanizeVariableName(attr)
        tooltip = Ahorn.expandTooltipText(get(tooltips, sattr, ""))

        push!(res, Ahorn.Form.suggestOption(displayName, value, tooltip=tooltip, dataName=attr, choices=keyOptions, editable=true))
    end

    return res
end

function createWindow()
    baseLangdata = get(Ahorn.langdata, :settings)
    
    configData = Ahorn.config.data
    configLangdata = get(baseLangdata, :config)
    configOptions = getOptions(configData, Dict{String, Any}(), configLangdata)
    configSection = Ahorn.Form.Section("General", configOptions, dataName="config")

    debugData = Ahorn.debug.config.data
    debugLangdata = get(baseLangdata, :debug)
    debugOptions = getOptions(debugData, Dict{String, Any}(), debugLangdata)
    debugSection = Ahorn.Form.Section("Debug", debugOptions, dataName="debug")

    sections = Ahorn.Form.Section[
        configSection, debugSection
    ]

    function callback(data::Dict{String, Dict{String, Any}})
        merge!(Ahorn.config.data, data["config"])
        merge!(Ahorn.debug.config.data, data["debug"])

        Ahorn.saveConfig(Ahorn.config)
        Ahorn.saveConfig(Ahorn.debug.config)

        # Todo - Specially handle some values
        #  language
        #  etc
    end

    settingsWindow = Ahorn.Form.createFormWindow("$(Ahorn.baseTitle) - Settings", sections, callback=callback)

    return settingsWindow
end

function showSettings(widget::Union{Ahorn.MenuItemsTypes, Nothing}=nothing)
    if settingsWindow !== nothing
        Gtk.destroy(settingsWindow)
    end

    try
        global settingsWindow = createWindow()

    catch e
        println(Base.stderr, e)
        println.(Ref(Base.stderr), stacktrace())
        println(Base.stderr, "---")
    end

    showall(settingsWindow)
end

end