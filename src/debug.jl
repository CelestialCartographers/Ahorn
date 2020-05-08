module debug

using ..Ahorn, Maple

config = Dict{String, Any}()

const defaultIgnoredTooltipAttrs = String["x", "y", "width", "height", "originX", "originY", "nodes"]

function setConfig(fn::String, buffertime::Int=0)
    global config = Ahorn.attemptLoadConfig(fn, buffertime)
end

function log(s::String, shouldPrint::Bool)
    if shouldPrint
        println(s)
    end
end

function log(s::String, key::String)
    if get(config, key, false)
        println(s)
    end
end

function reloadTools!()
    empty!(Ahorn.loadedTools)
    append!(Ahorn.loadedTools, joinpath.(Ahorn.abs"tools", readdir(Ahorn.abs"tools")))
    Ahorn.initExternalTools()

    Ahorn.loadModule.(Ahorn.loadedTools)
    Ahorn.loadExternalModules!(Ahorn.loadedModules, Ahorn.loadedTools, "tools")
    Ahorn.changeTool!(Ahorn.loadedTools[1])
    Ahorn.selectRow!(Ahorn.toolList, 1)

    return true
end

function reloadEntities!()
    dr = Ahorn.getDrawableRoom(Ahorn.loadedState.map, Ahorn.loadedState.room)

    empty!(Ahorn.loadedEntities)
    append!(Ahorn.loadedEntities, joinpath.(Ahorn.abs"entities", readdir(Ahorn.abs"entities")))
    Ahorn.initExternalEntities()

    Ahorn.loadModule.(Ahorn.loadedEntities)
    Ahorn.loadExternalModules!(Ahorn.loadedModules, Ahorn.loadedEntities, "entities")
    Ahorn.registerPlacements!(Ahorn.entityPlacements, Ahorn.loadedEntities)

    Ahorn.getLayerByName(dr.layers, "entities").redraw = true
    Ahorn.selectRow!(Ahorn.roomList, row -> row[1] == Ahorn.loadedState.roomName)

    Ahorn.fillPlacementCache!(Ahorn.entityPlacementsCache, Ahorn.entityPlacements)

    empty!(Ahorn.entityNameLookup)

    return true
end

function reloadEffects!()
    empty!(Ahorn.loadedEffects)
    append!(Ahorn.loadedEffects, joinpath.(Ahorn.abs"effects", readdir(Ahorn.abs"effects")))
    Ahorn.initExternalEffects()

    Ahorn.loadModule.(Ahorn.loadedEffects)
    Ahorn.loadExternalModules!(Ahorn.loadedModules, Ahorn.loadedEffects, "effects")
    Ahorn.registerPlacements!(Ahorn.effectPlacements, Ahorn.loadedEffects)

    return true
end

function reloadTriggers!()
    dr = Ahorn.getDrawableRoom(Ahorn.loadedState.map, Ahorn.loadedState.room)

    empty!(Ahorn.loadedTriggers)
    append!(Ahorn.loadedTriggers, joinpath.(Ahorn.abs"triggers", readdir(Ahorn.abs"triggers")))
    Ahorn.initExternalTriggers()

    Ahorn.loadModule.(Ahorn.loadedTriggers)
    Ahorn.loadExternalModules!(Ahorn.loadedModules, Ahorn.loadedTriggers, "triggers")
    Ahorn.registerPlacements!(Ahorn.triggerPlacements, Ahorn.loadedTriggers)

    Ahorn.getLayerByName(dr.layers, "triggers").redraw = true
    Ahorn.selectRow!(Ahorn.roomList, row -> row[1] == Ahorn.loadedState.roomName)

    Ahorn.fillPlacementCache!(Ahorn.triggerPlacementsCache, Ahorn.triggerPlacements)

    return true
end

function clearMapDrawingCache!(map::Maple.Map=Ahorn.loadedState.map)
    Ahorn.deleteDrawableRoomCache(map)
    Ahorn.draw(Ahorn.canvas)

    return true
end

function forceDrawWholeMap!(map::Maple.Map=Ahorn.loadedState.map)
    ctx = Ahorn.Gtk.getgc(Ahorn.canvas)

    for room in map.rooms
        dr = Ahorn.getDrawableRoom(map, room)

        Ahorn.drawRoom(ctx, Ahorn.camera, dr, alpha=1.0)
    end

    Ahorn.draw(Ahorn.canvas)

    return true
end

function checkTooltipCoverage(ignore::Array{String, 1}=defaultIgnoredTooltipAttrs)
    missing = Dict{String, Array{String, 1}}()

    for (cache, placements) in ((Ahorn.entityPlacementsCache, Ahorn.entityPlacements), (Ahorn.triggerPlacementsCache, Ahorn.triggerPlacements))
        for (name, placement) in placements
            target = Ahorn.getCachedPlacement!(cache, placements, name)
            key = isa(target, Maple.Entity) ? "entities" : "triggers"
            tooltips = get(Ahorn.langdata, ["placements", key, target.name, "tooltips"])

            if !haskey(missing, target.name)
                missing[target.name] = String[]
            end

            for (attr, value) in target.data
                if !(attr in missing[target.name]) && !haskey(tooltips, Symbol(attr)) && !(attr in ignore)
                    push!(missing[target.name], attr)
                end
            end
        end
    end

    println("-- Missing Tooltips --")
    
    for (name, attrs) in missing
        if !isempty(attrs)
            println(name)
        end

        for attr in attrs
            println("    $attr")
        end
    end
end

function reloadLangdata()
    return Ahorn.loadLangfile()
end

# Put on a method definition to time every call of it.
macro timemachine(expr)
    @assert expr.head in (:function, :(=))
    Expr(expr.head, expr.args[1], quote
        println("Method call: ", $(string(expr.args[1])))
        @time $(expr.args[2])
    end) |> esc
end

end