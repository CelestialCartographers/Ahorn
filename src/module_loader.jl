loadedModules = Dict{String, Module}()

function loadModule(fn::String)
    try
        loadedModules[fn] = include(fn)

        return true

    catch e
        println("! Failed to load \"$fn\"")
        println(e)

        return false
    end
end


hasModuleField(modul::Module, funcname::String) = isdefined(modul, Symbol(funcname))
hasModuleField(modul::String, funcname::String) = isdefined(loadedModules[modul], Symbol(funcname))

getModuleField(modul::Module, funcname::String) = getfield(modul, Symbol(funcname))
getModuleField(modul::String, funcname::String) = getfield(loadedModules[modul], Symbol(funcname))

function eventToModule(modul::Module, funcname::String, args...)
    if hasModuleField(modul, funcname)
        # Get function and call with arguments
        func = getModuleField(modul, funcname)

        if isa(func, Function) && applicable(func, args...)
            try
                return func(args...)

            catch e
                # Error running the function
                println("Exception running function $funcname for $modul")
                println(e)
                println.(stacktrace())
                println("---")
            end

        else
            # Can't call the function with the arguments we have
            # This is normal, event is not consumed
            
            return false
        end

    else
        # Module doesn't have the method
        # Return false as this cannot consume the event

        return false
    end
end

eventToModule(fn::String, funcname::String, args...) = eventToModule(loadedModules[fn], funcname, args...)
eventToModule(v::Void, funcname::String, args...) = false

function eventToModules(funcname::String, args...)
    for (filename, modul) in loadedModules
        moduleRes = eventToModule(modul, funcname, args...)
        if isa(moduleRes, Tuple) && moduleRes[1]
            return moduleRes

        elseif moduleRes == true
            return true
        end
    end

    return false
end

function eventToModules(moduleNames::Array{String, 1}, funcname::String, args...)
    for moduleName in moduleNames
        moduleRes = eventToModule(moduleName, funcname, args...)
        if isa(moduleRes, Tuple) && moduleRes[1]
            return moduleRes

        elseif moduleRes == true
            return true
        end
    end

    return false
end