module StylegroundWindow

using Gtk, Gtk.ShortNames, Gtk.GConstants
using Maple

stylegroundWindow = nothing

function initCombolBox!(widget, list)
    push!.(widget, list)
    setproperty!(widget, :active, 0)
end

function spawnWindowIfAbsent!()
    if stylegroundWindow === nothing
        global stylegroundWindow = createWindow()
    end
end

# Cleaner functions for gtk event callbacks
function showStylegroundWindow(widget=nothing, event=nothing)
    spawnWindowIfAbsent!()
    visible(stylegroundWindow, true)
    present(stylegroundWindow)

    return true
end

function hideStylegroundWindow(widget=nothing, event=nothing)
    spawnWindowIfAbsent!()
    visible(stylegroundWindow, false)

    return true
end

# Prefer to parse as integer, parse as float if not
function parseNumber(s::String)
    try
        return parse(Int, s)

    catch ArgumentError
        return parse(Float64, s)
    end
end

function getParallaxData(p::Main.Parallax, fg::Bool)
    return (
        get(p.data, "texture", ""),
        fg,
        get(p.data, "x", 0),
        get(p.data, "y", 0),
        get(p.data, "only", "*"),
        get(p.data, "exclude", ""),
    )
end

function getEffectData(e::Main.Effect, fg::Bool)
    return (
        e.typ,
        fg,
        get(e.data, "only", "*"),
        get(e.data, "exclude", "")
    )
end

parallaxDataType = Tuple{String, Bool, Int, Int, String, String}
effectDataType = Tuple{String, Bool, String, String}

targetParallax = nothing
targetEffect = nothing

# Expand Apply types into parallaxes
# Easier to use for both coding and user perspective
# Can be unexpanded later, save some filespace
function expandApply!(styles::Main.Maple.Styleground)
    res = []

    for style in styles.children
        if isa(style, Main.Maple.Apply)
            for p in style.parallax
                push!(res, Main.Maple.Parallax(merge(style.data, p.data)))
            end

        else
            push!(res, style)
        end
    end

    empty!(styles.children)
    push!(styles.children, res...)
end

function spritesToBackgroundTextures(sprites::Dict{String, Main.Sprite})
    res = String[]

    for (path, sprite) in sprites
        if startswith(path, "bgs/")
            push!(res, path)
        end
    end

    push!(res, "mist")
    push!(res, "purplesunset")
    push!(res, "northernlights")
    push!(res, "darkswamp")
    
    return res
end

function setFieldsFromEffect!(effect::Maple.Effect, fg::Bool=true, simple::Bool=get(Main.config, "use_simple_room_values", true))
    setproperty!(onlyEffectEntry, :text, string(get(effect.data, "only", "*")))
    setproperty!(excludeEffectEntry, :text, string(get(effect.data, "exclude", "")))

    setproperty!(effectCombo, :active, findfirst(effectChoices, lowercase(effect.typ)) - 1)

    setproperty!(foregroundEffectCheckbox, :active, fg)
end

function setEffectFromFields!(effect::Maple.Effect, simple::Bool=get(Main.config, "use_simple_room_values", true))
    try
        effect.data["only"] = getproperty(onlyEffectEntry, :text, String)
        effect.data["exclude"] = getproperty(excludeEffectEntry, :text, String)

        effect.typ = Gtk.bytestring(Gtk.GAccessor.active_text(effectCombo))

        fg = getproperty(foregroundEffectCheckbox, :active, Bool)

        return true, fg

    catch e
        println(e)
        return false, "Some of the inputs you have made might be incorrect."
    end
end

function setFieldsFromParallax!(parallax::Maple.Parallax, fg::Bool=trues)
    setproperty!(posXEntry, :text, string(round(Int, get(parallax.data, "x", 0))))
    setproperty!(posYEntry, :text, string(round(Int, get(parallax.data, "y", 0))))

    setproperty!(scrollXEntry, :text, string(get(parallax.data, "scrollx", 1)))
    setproperty!(scrollYEntry, :text, string(get(parallax.data, "scrolly", 1)))
    setproperty!(speedXEntry, :text, string(get(parallax.data, "speedx", 0)))
    setproperty!(speedYEntry, :text, string(get(parallax.data, "speedy", 0)))

    setproperty!(alphaEntry, :text, string(get(parallax.data, "alpha", 1)))
    setproperty!(colorEntry, :text, string(get(parallax.data, "color", "ffffff")))

    setproperty!(onlyEntry, :text, string(get(parallax.data, "only", "*")))
    setproperty!(excludeEntry, :text, string(get(parallax.data, "exclude", "")))

    Gtk.GLib.@sigatom setproperty!(backdropCombo, :active, findfirst(backdropChoices, get(parallax.data, "texture", "")) - 1)

    setproperty!(flipXCheckbox, :active, get(parallax.data, "flipx", false))
    setproperty!(flipYCheckbox, :active, get(parallax.data, "flipy", false))
    setproperty!(loopXCheckbox, :active, get(parallax.data, "loopx", true))
    setproperty!(loopYCheckbox, :active, get(parallax.data, "loopy", true))

    setproperty!(blendingCheckbox, :active, get(parallax.data, "blendmode", "alphablend") == "additive")
    setproperty!(instantInCheckbox, :active, get(parallax.data, "instantIn", true))

    setproperty!(foregroundCheckbox, :active, fg)
end

function setParallaxFromFields!(parallax::Maple.Parallax)
    try
        parallax.data["x"] = parseNumber(getproperty(posXEntry, :text, String))
        parallax.data["y"] = parseNumber(getproperty(posYEntry, :text, String))
        
        parallax.data["scrollx"] = parseNumber(getproperty(scrollXEntry, :text, String))
        parallax.data["scrolly"] = parseNumber(getproperty(scrollYEntry, :text, String))
        parallax.data["speedx"] = parseNumber(getproperty(speedXEntry, :text, String))
        parallax.data["speedy"] = parseNumber(getproperty(speedYEntry, :text, String))

        parallax.data["alpha"] = parseNumber(getproperty(alphaEntry, :text, String))
        parallax.data["color"] = getproperty(colorEntry, :text, String)

        parallax.data["only"] = getproperty(onlyEntry, :text, String)
        parallax.data["exclude"] = getproperty(excludeEntry, :text, String)

        parallax.data["texture"] = Gtk.bytestring(Gtk.GAccessor.active_text(backdropCombo))

        parallax.data["flipx"] = getproperty(flipXCheckbox, :active, Bool)
        parallax.data["flipy"] = getproperty(flipYCheckbox, :active, Bool)
        parallax.data["loopx"] = getproperty(loopXCheckbox, :active, Bool)
        parallax.data["loopy"] = getproperty(loopYCheckbox, :active, Bool)

        parallax.data["blendmode"] = getproperty(blendingCheckbox, :active, Bool)? "additive" : "alphablend"
        parallax.data["instantIn"] = getproperty(instantInCheckbox, :active, Bool)

        fg = getproperty(foregroundCheckbox, :active, Bool)

        return true, fg

    catch e
        println(e)
        return false, "Some of the inputs you have made might be incorrect."
    end
end

dataFuncs = Dict{Type, Function}(
    Maple.Parallax => getParallaxData,
    Maple.Effect => getEffectData
)

dataTuples = Dict{Type, Type}(
    Maple.Parallax => parallaxDataType,
    Maple.Effect => effectDataType
)

function selectParallax(row::parallaxDataType, fg::Bool, parallax::Union{Void, Maple.Parallax})
    parallax != nothing &&
    row[1] == get(parallax.data, "texture", "") &&
    row[2] == fg &&
    row[3] == get(parallax.data, "x", 0) &&
    row[4] == get(parallax.data, "y", 0) &&
    row[5] == get(parallax.data, "only", "*") &&
    row[6] == get(parallax.data, "exclude", "")
end

function selectEffect(row::effectDataType, fg::Bool, effect::Union{Void, Maple.Effect})
    effect != nothing &&
    row[1] == effect.typ &&
    row[2] == fg &&
    row[3] == get(effect.data, "only", "*") &&
    row[4] == get(effect.data, "exclude", "")
end

function updateLists!(container::Main.ListContainer, typ::Type, f::Union{Void, Function}=nothing)
    fgStyles = Main.loadedState.map.style.foregrounds
    bgStyles = Main.loadedState.map.style.backgrounds

    data = dataTuples[typ][]

    for styles in [bgStyles, fgStyles]
        expandApply!(styles)
        fg = styles === fgStyles

        for style in styles.children
            if isa(style, typ)
                push!(data, dataFuncs[typ](style, fg))
            end
        end
    end

    sort!(data, by=row -> (row[2], row[1]))

    selectAfter = isa(f, Function)? f : 1
    Main.updateTreeView!(container, data, selectAfter)
end

function removeFromStyles(style::Union{Maple.Parallax, Maple.Effect})
    fgStyles = Main.loadedState.map.style.foregrounds.children
    bgStyles = Main.loadedState.map.style.backgrounds.children

    data = parallaxList.store[selected(parallaxList.selection)]

    indexFg = findfirst(s -> s == style, fgStyles)
    indexBg = findfirst(s -> s == style, bgStyles)

    if indexFg != 0
        deleteat!(fgStyles, indexFg)
    end

    if indexBg != 0
        deleteat!(bgStyles, indexBg)
    end
end

function removeSelectedParallax(widget)
    if hasselection(parallaxList.selection)
        fgStyles = Main.loadedState.map.style.foregrounds
        bgStyles = Main.loadedState.map.style.backgrounds
    
        texture, fg, x, y, only, exclude = parallaxList.store[selected(parallaxList.selection)]
        styles = fg? fgStyles.children : bgStyles.children

        index = findfirst(p -> p == targetParallax, styles)
        if index != 0
            deleteat!(styles, index)
            updateLists!(parallaxList, Maple.Parallax, row -> selectParallax(row, fg, targetParallax))
        end
    end
end

function addParallax(widget)
    parallax = Maple.Parallax()
    success, fg = setParallaxFromFields!(parallax)

    if success
        fgStyles = Main.loadedState.map.style.foregrounds
        bgStyles = Main.loadedState.map.style.backgrounds
    
        styles = fg? fgStyles.children : bgStyles.children
        push!(styles, parallax)

        global targetParallax = parallax
        updateLists!(parallaxList, Maple.Parallax, row -> selectParallax(row, fg, targetParallax))

    else
        if isa(fg, String)
            warn_dialog(res, StylegroundWindow)
        end
    end
end

function editParallax(widget)
    if targetParallax !== nothing
        success, fg = setParallaxFromFields!(targetParallax)

        if success
            fgStyles = Main.loadedState.map.style.foregrounds
            bgStyles = Main.loadedState.map.style.backgrounds
        
            removeFromStyles(targetParallax)

            styles = fg? fgStyles.children : bgStyles.children
            push!(styles, targetParallax)

            updateLists!(parallaxList, Maple.Parallax, row -> selectParallax(row, fg, targetParallax))

        else
            if isa(fg, String)
                warn_dialog(res, StylegroundWindow)
            end
        end
    end
end

function removeSelectedEffect(widget)
    if hasselection(effectList.selection)
        fgStyles = Main.loadedState.map.style.foregrounds
        bgStyles = Main.loadedState.map.style.backgrounds
    
        typ, fg, only, exclude = effectList.store[selected(effectList.selection)]
        styles = fg? fgStyles.children : bgStyles.children

        index = findfirst(e -> e == targetEffect, styles)
        if index != 0
            deleteat!(styles, index)
            updateLists!(effectList, Maple.Effect, row -> selectEffect(row, fg, targetEffect))
        end
    end
end

function addEffect(widget)
    effect = Maple.Effect("Placeholder")
    success, fg = setEffectFromFields!(effect)

    if success
        fgStyles = Main.loadedState.map.style.foregrounds
        bgStyles = Main.loadedState.map.style.backgrounds
    
        styles = fg? fgStyles.children : bgStyles.children
        push!(styles, effect)

        global targetEffect = effect
        updateLists!(effectList, Maple.Effect, row -> selectEffect(row, fg, targetEffect))
    else
        if isa(fg, String)
            warn_dialog(res, StylegroundWindow)
        end
    end
end

function editEffect(widget)
    if targetEffect !== nothing
        success, fg = setEffectFromFields!(targetEffect)

        if success
            fgStyles = Main.loadedState.map.style.foregrounds
            bgStyles = Main.loadedState.map.style.backgrounds
        
            removeFromStyles(targetEffect)

            styles = fg? fgStyles.children : bgStyles.children
            push!(styles, targetEffect)

            updateLists!(effectList, Maple.Effect, row -> selectEffect(row, fg, targetEffect))

        else
            if isa(fg, String)
                warn_dialog(res, StylegroundWindow)
            end
        end
    end
end

function editStylegrounds(widget::Gtk.GtkMenuItemLeaf=MenuItem())
    showStylegroundWindow()

    if Main.loadedState.map === nothing
        info_dialog("No map is currently loaded.", Main.window)

    else
        spawnWindowIfAbsent!()
        updateLists!(parallaxList, Maple.Parallax)
        updateLists!(effectList, Maple.Effect)
    end
end

effectChoices = String[
    "snowfg", "snowbg", "windsnow", "dreamstars",
    "stars", "mirrorfg", "reflectionfg", "tentacles",
    "northernlights", "bossstarfield", "petals", "heatwave",
    "corestarsfg"
]
sort!(effectChoices)

backdropChoices = spritesToBackgroundTextures(Main.sprites)
sort!(backdropChoices)

# Gtk Widgets
stylegroundGrid = Grid()

headsUpLabel = Label("All values here are in pixels and not tiles, as non multiples of 8 are commons for stylegrounds.\nAhorn will not render the stylegrounds for you.\nYou will need to test these ingame!")
GAccessor.justify(headsUpLabel, GConstants.GtkJustification.CENTER)

backdropPreview = Canvas(320, 180)
@guarded draw(backdropPreview) do widget
    ctx = Gtk.getgc(backdropPreview)
    texture = Gtk.bytestring(Gtk.GAccessor.active_text(backdropCombo))
    sprite = Main.getSprite(texture)

    if sprite.width > 0 && sprite.height > 0
        Main.clearSurface(ctx)
        Main.drawImage(ctx, sprite, -sprite.offsetX, -sprite.offsetY)

    else
        Main.clearSurface(ctx)
        Main.centeredText(ctx, "Unable to preview backdrop.", 160, 90, fontsize=16)
    end
end

parallaxList = Main.generateTreeView(("Backdrop", "Foreground", "X", "Y", "Rooms", "Exclude"), parallaxDataType[], sortable=false)
Main.connectChanged(parallaxList, function(list::Main.ListContainer, row)
    fgStyles = Main.loadedState.map.style.foregrounds
    bgStyles = Main.loadedState.map.style.backgrounds

    texture, fg, x, y, only, exclude = row
    styles = fg? fgStyles.children : bgStyles.children
    index = findfirst(e -> (
        isa(e, Maple.Parallax) &&
        get(e.data, "texture", "") == texture &&
        get(e.data, "x", 0) == x &&
        get(e.data, "y", 0) == y &&
        get(e.data, "only", "*") == only &&
        get(e.data, "exclude", "") == exclude
    ), styles)
    if index != 0
        global targetParallax = styles[index]
        setFieldsFromParallax!(targetParallax, fg)
    end
end)

effectList = Main.generateTreeView(("Effect", "Foreground", "Rooms", "Exclude"), effectDataType[], sortable=false)
Main.connectChanged(effectList, function(list::Main.ListContainer, row)
    fgStyles = Main.loadedState.map.style.foregrounds
    bgStyles = Main.loadedState.map.style.backgrounds

    effect, fg, only, exclude = row
    styles = fg? fgStyles.children : bgStyles.children
    index = findfirst(e -> (
        isa(e, Maple.Effect) &&
        e.typ == effect &&
        get(e.data, "only", "*") == only &&
        get(e.data, "exclude", "") == exclude
    ), styles)
    if index != 0
        global targetEffect = styles[index]
        setFieldsFromEffect!(targetEffect, fg)
    end
end)

scrollableParallaxList = ScrolledWindow(hexpand=true, vexpand=true, hscrollbar_policy=Gtk.GtkPolicyType.NEVER)
push!(scrollableParallaxList, parallaxList.tree)

scrollableEffectList = ScrolledWindow(hexpand=true, vexpand=true, hscrollbar_policy=Gtk.GtkPolicyType.NEVER)
push!(scrollableEffectList, effectList.tree)

backdropCombo = ComboBoxText(true)
initCombolBox!(backdropCombo, backdropChoices)

posXEntry = Entry(text="0")
posYEntry = Entry(text="0")

scrollXEntry = Entry(text="1")
scrollYEntry = Entry(text="1")
speedXEntry = Entry(text="0")
speedYEntry = Entry(text="0")

alphaEntry = Entry(text="1")
colorEntry = Entry(text="ffffff")

onlyEntry = Entry(text="*")
excludeEntry = Entry(text="")

flipXCheckbox = CheckButton("Flip X")
flipYCheckbox = CheckButton("Flip Y")
loopXCheckbox = CheckButton("Loop X", active=true)
loopYCheckbox = CheckButton("Loop Y", active=true)

foregroundCheckbox = CheckButton("Foreground")
blendingCheckbox = CheckButton("Additive Blending")
instantInCheckbox = CheckButton("Instant In", active=true)

backdropLabel = Label("Backdrop")

posXLabel = Label("X")
posYLabel = Label("Y")

scrollXLabel = Label("Scroll X")
scrollYLabel = Label("Scroll Y")
speedXLabel = Label("Speed X")
speedYLabel = Label("Speed Y")

alphaLabel = Label("Alpha")
colorLabel = Label("Tinting (Hex color)")

onlyLabel = Label("Only")
excludeLabel = Label("Exclude")

setproperty!(posXLabel, :xalign, 0.1)
setproperty!(posYLabel, :xalign, 0.1)
setproperty!(scrollXLabel, :xalign, 0.1)
setproperty!(scrollYLabel, :xalign, 0.1)
setproperty!(speedXLabel, :xalign, 0.1)
setproperty!(speedYLabel, :xalign, 0.1)
setproperty!(alphaLabel, :xalign, 0.1)
setproperty!(colorLabel, :xalign, 0.1)
setproperty!(onlyLabel, :xalign, 0.1)
setproperty!(excludeLabel, :xalign, 0.1)

parallaxAdd = Button("Add")
parallaxRemove = Button("Remove")
parallaxUpdate = Button("Update")

signal_connect(addParallax, parallaxAdd, "clicked")
signal_connect(removeSelectedParallax, parallaxRemove, "clicked")
signal_connect(editParallax, parallaxUpdate, "clicked")

effectCombo = ComboBoxText(true)
initCombolBox!(effectCombo, effectChoices)

onlyEffectEntry = Entry(text="*")
excludeEffectEntry = Entry(text="")

effectLabel = Label("Effect")
onlyEffectLabel = Label("Only")
excludeEffectLabel = Label("Exclude")

foregroundEffectCheckbox = CheckButton("Foreground")

setproperty!(effectLabel, :xalign, 0.1)
setproperty!(onlyEffectLabel, :xalign, 0.1)
setproperty!(excludeEffectLabel, :xalign, 0.1)

effectAdd = Button("Add")
effectRemove = Button("Remove")
effectUpdate = Button("Update")

signal_connect(addEffect, effectAdd, "clicked")
signal_connect(removeSelectedEffect, effectRemove, "clicked")
signal_connect(editEffect, effectUpdate, "clicked")

stylegroundGrid[1:6, 1] = scrollableParallaxList
stylegroundGrid[7:8, 1] = backdropPreview

stylegroundGrid[1, 2] = posXLabel
stylegroundGrid[2, 2] = posXEntry
stylegroundGrid[3, 2] = posYLabel
stylegroundGrid[4, 2] = posYEntry
stylegroundGrid[5, 2] = backdropLabel
stylegroundGrid[6, 2] = backdropCombo
stylegroundGrid[7, 2] = foregroundCheckbox

stylegroundGrid[1, 3] = scrollXLabel
stylegroundGrid[2, 3] = scrollXEntry
stylegroundGrid[3, 3] = scrollYLabel
stylegroundGrid[4, 3] = scrollYEntry
stylegroundGrid[5, 3] = speedXLabel
stylegroundGrid[6, 3] = speedXEntry
stylegroundGrid[7, 3] = speedYLabel
stylegroundGrid[8, 3] = speedYEntry

stylegroundGrid[1, 4] = onlyLabel
stylegroundGrid[2, 4] = onlyEntry
stylegroundGrid[3, 4] = excludeLabel
stylegroundGrid[4, 4] = excludeEntry
stylegroundGrid[5, 4] = alphaLabel
stylegroundGrid[6, 4] = alphaEntry
stylegroundGrid[7, 4] = colorLabel
stylegroundGrid[8, 4] = colorEntry

stylegroundGrid[1, 5] = flipXCheckbox
stylegroundGrid[2, 5] = flipYCheckbox
stylegroundGrid[3, 5] = loopXCheckbox
stylegroundGrid[4, 5] = loopYCheckbox
stylegroundGrid[5, 5] = instantInCheckbox
stylegroundGrid[6, 5] = blendingCheckbox

stylegroundGrid[1:2, 9] = parallaxAdd
stylegroundGrid[3:4, 9] = parallaxRemove
stylegroundGrid[4:8, 9] = parallaxUpdate

stylegroundGrid[1:8, 10] = scrollableEffectList

stylegroundGrid[1, 11] = effectLabel
stylegroundGrid[2, 11] = effectCombo
stylegroundGrid[3, 11] = onlyEffectLabel
stylegroundGrid[4, 11] = onlyEffectEntry
stylegroundGrid[5, 11] = excludeEffectLabel
stylegroundGrid[6, 11] = excludeEffectEntry
stylegroundGrid[7, 11] = foregroundEffectCheckbox

stylegroundGrid[1:2, 12] = effectAdd
stylegroundGrid[3:4, 12] = effectRemove
stylegroundGrid[4:8, 12] = effectUpdate

stylegroundGrid[1:8, 20] = headsUpLabel

function createWindow()
    stylegroundWindow = Window("$(Main.baseTitle) - Edit stylegrounds", -1, -1, true, icon = Main.windowIcon, gravity = GdkGravity.GDK_GRAVITY_CENTER
    ) |> (Frame() |> (stylegroundBox = Box(:v)))

    # Hide window instead of destroying it
    signal_connect(hideStylegroundWindow, stylegroundWindow, "delete_event")
    
    push!(stylegroundBox, stylegroundGrid)
    showall(stylegroundWindow)

    @guarded signal_connect(widget -> draw(backdropPreview), backdropCombo, "changed")

    setproperty!(stylegroundWindow, :height_request, height(stylegroundWindow) + 400)

    return stylegroundWindow
end

end