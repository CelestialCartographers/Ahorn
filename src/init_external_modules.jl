function initExternalEntities()
    externalEntities = findExternalModules("entities")
    append!(loadedEntities, externalEntities)
    loadModule.(externalEntities)
    loadExternalModules!(loadedModules, loadedEntities, "entities")
    registerPlacements!(entityPlacements, loadedEntities)
end

function initExternalTriggers()
    externalTriggers = findExternalModules("triggers")
    append!(loadedTriggers, externalTriggers)
    loadModule.(externalTriggers)
    loadExternalModules!(loadedModules, loadedTriggers, "triggers")
    registerPlacements!(triggerPlacements, loadedTriggers)
end

function initExternalEffects()
    externalEffects = findExternalModules("ffects")
    append!(loadedEffects, externalEffects)
    loadModule.(externalEffects)
    loadExternalModules!(loadedModules, loadedEffects, "effects")
    registerPlacements!(effectPlacements, loadedEffects)
end

function initExternalTools()
    externalTools = findExternalModules("tools")
    append!(loadedTools, externalTools)
    loadModule.(externalTools)
    loadExternalModules!(loadedModules, loadedTools, "tools")
end

function initExternalModules()
    initExternalEntities()
    initExternalTriggers()
    initExternalEffects()
    initExternalTools()
end