function initExternalEntities()
    externalEntities = findExternalModules("entities")
    append!(loadedEntities, externalEntities)
    loadModule.(externalEntities)
    loadExternalZipModules!(loadedModules, loadedEntities, "entities")
    registerPlacements!(entityPlacements, loadedEntities)
end

function initExternalTriggers()
    externalTriggers = findExternalModules("triggers")
    append!(loadedTriggers, externalTriggers)
    loadModule.(externalTriggers)
    loadExternalZipModules!(loadedModules, loadedTriggers, "triggers")
    registerPlacements!(triggerPlacements, loadedTriggers)
end

function initExternalEffects()
    externalEffects = findExternalModules("effects")
    append!(loadedEffects, externalEffects)
    loadModule.(externalEffects)
    loadExternalZipModules!(loadedModules, loadedEffects, "effects")
    registerPlacements!(effectPlacements, loadedEffects)
end

function initExternalLibraries()
    externalLibraries = findExternalModules("libraries")
    append!(loadedLibraries, externalLibraries)
    loadModule.(externalLibraries)
    loadExternalZipModules!(loadedModules, loadedLibraries, "libraries")
end

function initExternalTools()
    externalTools = findExternalModules("tools")
    append!(loadedTools, externalTools)
    loadModule.(externalTools)
    loadExternalZipModules!(loadedModules, loadedTools, "tools")
end

function initExternalModules()
    initExternalLibraries()
    initExternalEntities()
    initExternalTriggers()
    initExternalEffects()
    initExternalTools()
end
