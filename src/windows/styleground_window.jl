module StylegroundWindow

using Gtk, Gtk.ShortNames, Gtk.GConstants
using ..Ahorn, Maple

stylegroundWindow = nothing
effectSectionGrid = nothing
effectOptions = nothing

const effectFieldOrder = String[
    "name", "only", "exclude", "tag",
    "flag", "notflag"
]

const parallaxFieldOrder = String[
    "texture", "only", "exclude", "tag",
    "flag", "notflag", "blendmode", "color",
    "x", "y", "scrollx", "scrolly",
    "speedx", "speedy", "alpha"
]

function drawPreviewFailed(canvas::Gtk.GtkCanvas, reason::String, width::Int=320, height::Int=180, scale::Number=3)
    ctx = Gtk.getgc(canvas)

    set_gtk_property!(canvas, :width_request, width)
    set_gtk_property!(canvas, :height_request, height)

    Ahorn.clearSurface(ctx)
    Ahorn.drawCenteredText(ctx, reason, 0, 0, width, height, scale=scale)
end

function drawPreview(canvas::Gtk.GtkCanvas, textureOption::Ahorn.Form.Option, colorOption::Ahorn.Form.Option)
    ctx = Gtk.getgc(canvas)
    texture = Ahorn.Form.getValue(textureOption)
    sprite = Ahorn.getSprite(texture, "Gameplay")
    rawColor = Ahorn.Form.getValue(colorOption)

    width, height = sprite.width, sprite.height

    if width > 0 && height > 0 && !(sprite.surface == Ahorn.Assets.missingImage)
        try
            @assert length(rawColor) == 6
            color = Ahorn.argb32ToRGBATuple(parse(Int, "0x" * rawColor) + 255 << 24) ./ 255.0

            offsetX, offsetY = sprite.offsetX, sprite.offsetY

            set_gtk_property!(canvas, :width_request, width)
            set_gtk_property!(canvas, :height_request, height)

            Ahorn.clearSurface(ctx)
            Ahorn.drawImage(ctx, sprite, -offsetX, -offsetY, tint=color)

        catch e
            drawPreviewFailed(canvas, "Color is invalid.\nExpected hex triplet without #.")
        end

    else
        drawPreviewFailed(canvas, "Unable to preview backdrop, image not found.\nAhorn can only preview from the Gameplay atlas.")
    end
end

function spritesToBackgroundTextures(sprites::Dict{String, Ahorn.SpriteHolder})
    Ahorn.loadChangedExternalSprites!()

    res = String[]

    for (path, spriteHolder) in sprites
        if startswith(path, "bgs/")
            if spriteHolder.sprite.width > 0 && spriteHolder.sprite.height > 0
                push!(res, path)
            end
        end
    end
    
    push!(res, "mist")
    push!(res, "purplesunset")
    push!(res, "northernlights")
    push!(res, "darkswamp")

    sort!(res)
    
    return res
end

const parallaxFields = Dict{String, Any}(
    "x" => 0.0,
    "y" => 0.0,

    "scrollx" => 1.0,
    "scrolly" => 1.0,
    "speedx" => 0.0,
    "speedy" => 0.0,

    "alpha" => 1.0,
    "color" => "FFFFFF",

    "only" => "*",
    "exclude" => "",

    "texture" => "",

    "flipx" => false,
    "flipy" => false,
    "loopx" => true,
    "loopy" => true,

    "flag" => "",
    "notflag" => "",

    "blendmode" => "alphablend",
    "instantIn" => false,
    "instantOut" => false,
    "fadeIn" => false,

    "tag" => ""
)

# Additional fields to add when creating an Effect
const effectFields = Dict{String, Any}(
    "flag" => "",
    "notflag" => "",
    "tag" => "",
    
    "fg" => true
)

# Fake fields that are not set in the data, but makes sense to have options for
const parallaxFakeFields = Dict{String, Any}(
    "fg" => true
)

const effectTemplates = Dict{String, Dict{String, Any}}(

)

function updateEffectTemplates()
    for effect in Ahorn.effectPlacements
        e = effect()
        effectTemplates[e.name] = merge(effectFields, e.data)
    end
end

function getParallaxListRow(backdrop::Maple.Parallax, fg::Bool=true)
    return (
        get(backdrop, "texture", ""),
        fg,
        get(backdrop, "x", 0.0),
        get(backdrop, "y", 0.0),
        get(backdrop, "only", "*"),
        get(backdrop, "exclude", ""),
    )
end

function getEffectListRow(backdrop::Maple.Effect, fg::Bool=true)
    return (
        backdrop.name,
        fg,
        get(backdrop, "only", "*"),
        get(backdrop, "exclude", "")
    )
end

function getParallaxListRows(style::Maple.Style)
    Maple.expandStylegroundApplies!(style)
    rows = Tuple{String, Bool, Float64, Float64, String, String, Int}[]

    for (fg, backdrops) in ((true, style.foregrounds), (false, style.backgrounds))
        for (i, backdrop) in enumerate(backdrops)
            if isa(backdrop, Maple.Parallax)
                push!(rows, (getParallaxListRow(backdrop, fg)..., i))
            end
        end
    end

    return rows
end

function getEffectListRows(style::Maple.Style)
    Maple.expandStylegroundApplies!(style)
    rows = Tuple{String, Bool, String, String, Int}[]

    for (fg, backdrops) in ((true, style.foregrounds), (false, style.backgrounds))
        for (i, backdrop) in enumerate(backdrops)
            if isa(backdrop, Maple.Effect)
                push!(rows, (getEffectListRow(backdrop, fg)..., i))
            end
        end
    end

    return rows
end

function getBackdrop(map::Maple.Map, fg::Bool, index::Int)
    backdrops = fg ? map.style.foregrounds : map.style.backgrounds

    return backdrops[index]
end

function getListIndices(list::Ahorn.ListContainer, fgCol::Int, indexCol::Int)
    fgIndices = Int[]
    bgIndices = Int[]

    for row in list.data
        fg = row[fgCol]
        index = row[indexCol]

        push!(fg ? fgIndices : bgIndices, index)
    end

    return fgIndices, bgIndices
end

function moveBackdrop!(target::Array{Maple.Backdrop, 1}, indices::Array{Int, 1}, index::Int, offset::Int)
    indicesIndex = findfirst(isequal(index), indices)
    newIndex = indices[clamp(indicesIndex + offset, 1, length(indices))]

    if index != newIndex && 1 <= index <= length(target)
        value = target[index]
        deleteat!(target, index)
        insert!(target, newIndex, value)

        return true
    end

    return false
end

function getParallaxOptions(fields::Dict{String, Any}, langdata::Ahorn.LangData)
    options = Ahorn.Form.Option[]

    # Make sure we get a new list of valid textures
    dropdownOptions = Dict{String, Any}(
        "texture" => sort(spritesToBackgroundTextures(Ahorn.getAtlas("Gameplay"))),
        "blendmode" => String[
            "additive", "alphablend"
        ]
    )

    names = get(langdata, :names)
    tooltips = get(langdata, :tooltips)

    for (dataName, value) in fields
        symbolDataName = Symbol(dataName)
        keyOptions = get(dropdownOptions, dataName, nothing)
        displayName = haskey(names, symbolDataName) ? names[symbolDataName] : Ahorn.humanizeVariableName(dataName)
        tooltip = Ahorn.expandTooltipText(get(tooltips, symbolDataName, ""))

        push!(options, Ahorn.Form.suggestOption(displayName, value, tooltip=tooltip, dataName=dataName, choices=keyOptions, editable=true))
    end

    return options
end

function getEffectOptions(effect::Maple.Effect, langdata::Ahorn.LangData, fg::Bool=true)
    updateEffectTemplates()

    options = Ahorn.Form.Option[]

    # Make sure we get a new list of valid names
    nameOptions = Dict{String, Any}(
        "name" => sort(collect(keys(effectTemplates))),
    )

    names = get(langdata, :names)
    tooltips = get(langdata, :tooltips)
    dropdownOptions = merge(
        Ahorn.editingOptions(effect),
        nameOptions
    )

    data = effect.data
    data["name"] = effect.name

    canFg, canBg = Ahorn.canFgBg(effect)

    if canFg && canBg
        data["fg"] = fg
    end

    for (dataName, value) in merge(effectFields, data)
        symbolDataName = Symbol(dataName)
        keyOptions = get(dropdownOptions, dataName, nothing)
        displayName = haskey(names, symbolDataName) ? names[symbolDataName] : Ahorn.humanizeVariableName(dataName)
        tooltip = Ahorn.expandTooltipText(get(tooltips, symbolDataName, ""))

        push!(options, Ahorn.Form.suggestOption(displayName, value, tooltip=tooltip, dataName=dataName, choices=keyOptions, editable=true))
    end

    return options
end

function updateEffect(effect::Maple.Effect, data::Dict{String, Any}, fg::Bool=true)
    updateEffectTemplates()

    newName = data["name"]
    res = Effect(newName, Dict{String, Any}())

    if effect.name != newName
        for (attr, value) in effectTemplates[newName]
            res.data[attr] = get(effect.data, attr, value)
        end

        res.data = merge(get(effectTemplates, newName, Dict{String, Any}()), effect.data)

    else
        res.data = data
    end

    delete!(res.data, "fg")

    return res
end

function moveIllegalFgBg(map::Maple.Map)
    moved = false
    style = map.style

    for (fg, backdrops) in ((true, style.foregrounds), (false, style.backgrounds))
        for i in length(backdrops):-1:1
            backdrop = backdrops[i]

            if isa(backdrop, Maple.Effect)
                canFg, canBg = Ahorn.canFgBg(backdrop)

                if fg && !canFg
                    moved = true
                    deleteat!(style.foregrounds, i)
                    push!(style.backgrounds, backdrop)

                elseif !fg && !canBg
                    moved = true
                    deleteat!(style.backgrounds, i)
                    push!(style.foregrounds, backdrop)
                end
            end
        end
    end

    return moved
end

function filterFakeFields!(data::Dict{String, Any}, fake::Dict{String, Any})
    return filter(pair -> !(haskey(fake, pair[1])), data)
end

function updateEffectSectionGrid(grid::Gtk.GtkGrid, backdrop::Maple.Effect, fg::Bool=true)
    if effectSectionGrid !== nothing
        Gtk.destroy(effectSectionGrid)
    end

    langdataEffects = get(Ahorn.langdata, [:styleground_window, :effects])
    langdataEffect = get(Ahorn.langdata, [:placements, :effects, Symbol(backdrop.name)])

    langdataCombined = Ahorn.LangData(Dict{Symbol, Any}(
        :names => merge(get(langdataEffect, :names), get(langdataEffects, :names)),
        :tooltips => merge(get(langdataEffect, :tooltips), get(langdataEffects, :tooltips))
    ))

    global effectOptions = getEffectOptions(backdrop, langdataCombined, fg)
    section = Ahorn.Form.Section("Effect", effectOptions, fieldOrder=effectFieldOrder)
    global effectSectionGrid = Ahorn.Form.generateSectionGrid(section, columns=8)

    set_gtk_property!(effectSectionGrid, :hexpand, true)
    Ahorn.Form.setGtkProperty!.(effectOptions, :hexpand, true)

    grid[1:8, 2] = effectSectionGrid

    nameOption = Ahorn.Form.getOptionByDataName(effectOptions, "name")
    fgOption = Ahorn.Form.getOptionByDataName(effectOptions, "fg")

    signal_connect(nameOption.combobox, "changed") do widget
        newName = Ahorn.Form.getValue(nameOption)
        backdrop = Effect(newName, effectTemplates[newName])

        fg = fgOption !== nothing ? Ahorn.Form.getValue(fgOption) : fg

        updateEffectSectionGrid(grid, backdrop, fg)
    end

    showall(grid)
end

function getParallaxGrid(map::Maple.Map)
    grid = Grid()

    parallaxList = Ahorn.generateTreeView(
        ("Backdrop", "Foreground", "X", "Y", "Rooms", "Exclude", "Index"),
        getParallaxListRows(map.style),
        sortable=false,
        visible=[
            true, true, true, true,
            true, true, false
        ]
    )

    scrollableList = ScrolledWindow(vexpand=true, hexpand=true, hscrollbar_policy=Gtk.GtkPolicyType.NEVER)
    push!(scrollableList, parallaxList.tree)

    fields = merge(parallaxFields, parallaxFakeFields)
    langdataParallax = get(Ahorn.langdata, [:styleground_window, :parallax])
    options = getParallaxOptions(fields, langdataParallax)
    section = Ahorn.Form.Section("Parallax", options, fieldOrder=parallaxFieldOrder)
    sectionGrid = Ahorn.Form.generateSectionGrid(section, columns=8)

    set_gtk_property!(sectionGrid, :hexpand, true)
    Ahorn.Form.setGtkProperty!.(options, :hexpand, true)

    textureOption = Ahorn.Form.getOptionByDataName(options, "texture")
    colorOption = Ahorn.Form.getOptionByDataName(options, "color")
    fgOption = Ahorn.Form.getOptionByDataName(options, "fg")

    preview = Canvas(320, 180)

    addButton = Button("Add")
    removeButton = Button("Remove")
    updateButton = Button("Update")
    upButton = Button("↑")
    downButton = Button("↓")

    function parallaxRowHandler(list, row)
        index = row[7]
        fg = row[2]

        backdrop = getBackdrop(map, fg, index)
        Ahorn.Form.setOptionsData!(options, merge(parallaxFields, backdrop.data))
        Ahorn.Form.setValue!(fgOption, fg)
    end

    @guarded signal_connect(addButton, "clicked") do widget
        data, incorrectOptions = Ahorn.Form.getOptionsData(options)

        if data !== nothing
            fg = Ahorn.Form.getValue(fgOption)

            backdrops = fg ? map.style.foregrounds : map.style.backgrounds
            backdrop = Parallax(filterFakeFields!(data, parallaxFakeFields))

            if hasselection(parallaxList.selection)
                row = parallaxList.data[Ahorn.getSelected(parallaxList, 1)]
                index = row[7]
                targetFg = row[2]

                if targetFg == fg
                    insert!(backdrops, index + 1, backdrop)

                else
                    push!(backdrops, backdrop)
                end

            else
                push!(backdrops, backdrop)
            end

            Ahorn.updateTreeView!(parallaxList, getParallaxListRows(map.style), Ahorn.currentRow(parallaxList) + 1, updateByReplacement=true)

        else
            Ahorn.topMostInfoDialog(Ahorn.Form.getIncorrectOptionsMessage(incorrectOptions), stylegroundWindow)
        end
    end

    @guarded signal_connect(removeButton, "clicked") do widget
        if hasselection(parallaxList.selection)
            row = parallaxList.data[Ahorn.getSelected(parallaxList)]
            index = row[7]
            fg = row[2]

            backdrops = fg ? map.style.foregrounds : map.style.backgrounds
            deleteat!(backdrops, index)

            Ahorn.updateTreeView!(parallaxList, getParallaxListRows(map.style), max(Ahorn.currentRow(parallaxList) - 1, 1), updateByReplacement=true)
        end
    end

    @guarded signal_connect(updateButton, "clicked") do widget
        if hasselection(parallaxList.selection)
            data, incorrectOptions = Ahorn.Form.getOptionsData(options)

            if data !== nothing
                row = parallaxList.data[Ahorn.getSelected(parallaxList)]
                index = row[7]
                fg = row[2]
                fgNew = Ahorn.Form.getValue(fgOption)

                if fg == fgNew
                    backdrops = fg ? map.style.foregrounds : map.style.backgrounds
                    backdrop = backdrops[index]
                    backdrop.data = data

                else
                    backdrops = fg ? map.style.foregrounds : map.style.backgrounds
                    backdropsNew = fgNew ? map.style.foregrounds : map.style.backgrounds
                    backdrop = backdrops[index]
                    backdrop.data = data

                    deleteat!(backdrops, index)
                    push!(backdropsNew, backdrop)
                end

                Ahorn.updateTreeView!(parallaxList, getParallaxListRows(map.style), Ahorn.currentRow(parallaxList), updateByReplacement=true)

            else
                Ahorn.topMostInfoDialog(Ahorn.Form.getIncorrectOptionsMessage(incorrectOptions), stylegroundWindow)
            end
        end
    end

    @guarded signal_connect(upButton, "clicked") do widget
        if hasselection(parallaxList.selection)
            row = parallaxList.data[Ahorn.getSelected(parallaxList)]
            index = row[7]
            fg = row[2]

            fgIndices, bgIndices = getListIndices(parallaxList, 2, 7)
            indices = fg ? fgIndices : bgIndices
            backdrops = fg ? map.style.foregrounds : map.style.backgrounds

            moved = moveBackdrop!(backdrops, indices, index, -1)
            select = moved ? Ahorn.currentRow(parallaxList) - 1 : nothing

            Ahorn.updateTreeView!(parallaxList, getParallaxListRows(map.style), select, updateByReplacement=true)
        end
    end

    @guarded signal_connect(downButton, "clicked") do widget
        if hasselection(parallaxList.selection)
            row = parallaxList.data[Ahorn.getSelected(parallaxList)]
            index = row[7]
            fg = row[2]

            fgIndices, bgIndices = getListIndices(parallaxList, 2, 7)
            indices = fg ? fgIndices : bgIndices
            backdrops = fg ? map.style.foregrounds : map.style.backgrounds

            moved = moveBackdrop!(backdrops, indices, index, 1)
            select = moved ? Ahorn.currentRow(parallaxList) + 1 : nothing

            Ahorn.updateTreeView!(parallaxList, getParallaxListRows(map.style), select, updateByReplacement=true)
        end
    end
    
    Ahorn.connectChanged(parallaxRowHandler, parallaxList)

    signal_connect(widget -> draw(preview), textureOption.combobox, "changed")
    signal_connect(widget -> draw(preview), colorOption.entry, "changed")

    @guarded draw(preview) do widget
        drawPreview(preview, textureOption, colorOption)
    end

    grid[1:6, 1] = scrollableList
    grid[7:8, 1] = preview
    grid[1:8, 2] = sectionGrid
    grid[1:2, 3] = addButton
    grid[3:4, 3] = removeButton
    grid[5:6, 3] = updateButton
    grid[7, 3] = upButton
    grid[8, 3] = downButton

    return grid
end

function getEffectGrid(map::Maple.Map)
    grid = Grid()
    
    effectList = Ahorn.generateTreeView(
        ("Backdrop", "Foreground", "Rooms", "Exclude", "Index"),
        getEffectListRows(map.style),
        sortable=false,
        visible=[
            true, true, true, true, false
        ]
    )

    scrollableList = ScrolledWindow(vexpand=true, hexpand=true, hscrollbar_policy=Gtk.GtkPolicyType.NEVER)
    push!(scrollableList, effectList.tree)

    global effectSectionGrid = nothing
    options = []

    addButton = Button("Add")
    removeButton = Button("Remove")
    updateButton = Button("Update")
    upButton = Button("↑")
    downButton = Button("↓")

    # Placeholder effect 
    updateEffectTemplates()
    templateEffectName = Ahorn.effectPlacements[1]().name
    templateEffectData = effectTemplates[templateEffectName]
    templateEffect = Effect(templateEffectName, templateEffectData)
    updateEffectSectionGrid(grid, templateEffect, true)

    function effectRowHandler(list, row)
        index = row[5]
        fg = row[2]

        backdrop = getBackdrop(map, fg, index)
        updateEffectSectionGrid(grid, backdrop, fg)
    end

    @guarded signal_connect(addButton, "clicked") do widget
        if hasselection(effectList.selection)
            data, incorrectOptions = Ahorn.Form.getOptionsData(effectOptions)

            if data !== nothing
                fgOption = Ahorn.Form.getOptionByDataName(effectOptions, "fg")
                row = effectList.data[Ahorn.getSelected(effectList, 1)]
                index = row[5]
                fg = row[2]
                fgNew = fgOption !== nothing ? Ahorn.Form.getValue(fgOption) : fg
                
                backdrops = fgNew ? map.style.foregrounds : map.style.backgrounds
                backdrop = Effect(row[1], Dict{String, Any}())
                backdrop = updateEffect(backdrop, data, fgNew)

                updateEffectSectionGrid(grid, backdrop, fgNew)

                if fg == fgNew
                    insert!(backdrops, index + 1, backdrop)

                else
                    push!(backdrops, backdrop)
                end
            
            else
                Ahorn.topMostInfoDialog(Ahorn.Form.getIncorrectOptionsMessage(incorrectOptions), stylegroundWindow)
            end

        else
            nameOption = Ahorn.Form.getOptionByDataName(effectOptions, "name")
            name = nameOption !== nothing ? Ahorn.Form.getValue(nameOption) : Ahorn.effectPlacements[1]().name
            backdrop = Effect(name, get(effectTemplates, name, Dict{String, Any}()))

            push!(map.style.foregrounds, backdrop)
        end

        select = moveIllegalFgBg(map) ? 0 : something(Ahorn.getSelected(effectList), 0) + 1
        Ahorn.updateTreeView!(effectList, getEffectListRows(map.style), select, updateByReplacement=true)
    end

    @guarded signal_connect(removeButton, "clicked") do widget
        if hasselection(effectList.selection)
            row = effectList.data[Ahorn.getSelected(effectList)]
            index = row[5]
            fg = row[2]

            backdrops = fg ? map.style.foregrounds : map.style.backgrounds
            deleteat!(backdrops, index)

            Ahorn.updateTreeView!(effectList, getEffectListRows(map.style), max(Ahorn.currentRow(effectList) - 1, 1), updateByReplacement=true)
        end
    end

    @guarded signal_connect(updateButton, "clicked") do widget
        if hasselection(effectList.selection)
            data, incorrectOptions = Ahorn.Form.getOptionsData(effectOptions)

            if data !== nothing
                fgOption = Ahorn.Form.getOptionByDataName(effectOptions, "fg")

                row = effectList.data[Ahorn.getSelected(effectList)]
                index = row[5]
                fg = row[2]
                fgNew = fgOption !== nothing ? Ahorn.Form.getValue(fgOption) : fg

                if fg == fgNew
                    backdrops = fg ? map.style.foregrounds : map.style.backgrounds
                    backdrop = backdrops[index]
                    backdrops[index] = updateEffect(backdrop, data, fgNew)

                else
                    backdrops = fg ? map.style.foregrounds : map.style.backgrounds
                    backdrop = backdrops[index]
                    backdrop = updateEffect(backdrop, data, fgNew)

                    backdropsNew = fgNew ? map.style.foregrounds : map.style.backgrounds

                    deleteat!(backdrops, index)
                    push!(backdropsNew, backdrop)
                end

                select = moveIllegalFgBg(map) ? 0 : something(Ahorn.getSelected(effectList), 0)
                Ahorn.updateTreeView!(effectList, getEffectListRows(map.style), select, updateByReplacement=true)

            else
                Ahorn.topMostInfoDialog(Ahorn.Form.getIncorrectOptionsMessage(incorrectOptions), stylegroundWindow)
            end
        end
    end

    @guarded signal_connect(upButton, "clicked") do widget
        if hasselection(effectList.selection)
            row = effectList.data[Ahorn.getSelected(effectList)]
            index = row[5]
            fg = row[2]

            fgIndices, bgIndices = getListIndices(effectList, 2, 5)
            indices = fg ? fgIndices : bgIndices
            backdrops = fg ? map.style.foregrounds : map.style.backgrounds

            moved = moveBackdrop!(backdrops, indices, index, -1)
            select = moved ? Ahorn.currentRow(effectList) - 1 : nothing

            Ahorn.updateTreeView!(effectList, getEffectListRows(map.style), select, updateByReplacement=true)
        end
    end

    @guarded signal_connect(downButton, "clicked") do widget
        if hasselection(effectList.selection)
            row = effectList.data[Ahorn.getSelected(effectList)]
            index = row[5]
            fg = row[2]

            fgIndices, bgIndices = getListIndices(effectList, 2, 5)
            indices = fg ? fgIndices : bgIndices
            backdrops = fg ? map.style.foregrounds : map.style.backgrounds

            moved = moveBackdrop!(backdrops, indices, index, 1)
            select = moved ? Ahorn.currentRow(effectList) : nothing

            Ahorn.updateTreeView!(effectList, getEffectListRows(map.style), select, updateByReplacement=true)
        end
    end
    
    Ahorn.connectChanged(effectRowHandler, effectList)

    grid[1:8, 1] = scrollableList
    grid[1:2, 3] = addButton
    grid[3:4, 3] = removeButton
    grid[5:6, 3] = updateButton
    grid[7, 3] = upButton
    grid[8, 3] = downButton

    return grid
end

function createStylegroundWindow(widget::Ahorn.MenuItemsTypes)
    if Ahorn.loadedState.map === nothing
        Ahorn.topMostInfoDialog("No map is currently loaded.", Ahorn.window)

    else
        @Ahorn.catchall begin
            map = Ahorn.loadedState.map

            Maple.expandStylegroundApplies!(map.style)

            box = Box(:v)

            notebook = Notebook()

            parallaxGrid = getParallaxGrid(map)
            parallaxBox = Box(:v)

            effectGrid = getEffectGrid(map)
            effectBox = Box(:v)

            push!(parallaxBox, parallaxGrid)
            push!(notebook, parallaxBox, "Parallax")

            push!(effectBox, effectGrid)
            push!(notebook, effectBox, "Effect")

            push!(box, notebook)

            if stylegroundWindow !== nothing
                Gtk.destroy(stylegroundWindow)
            end

            window = Window("$(Ahorn.baseTitle) - Stylegrounds", -1, -1, true, icon=Ahorn.windowIcon)
            push!(window, box)

            showall(window)

            global stylegroundWindow = window
        end
    end
end

end