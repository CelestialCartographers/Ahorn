const loadedModules = Dict{String, Module}()
const loadedModulesTimes = Dict{String, Float64}()

function loadModule(fn::String, force::Bool=false)
    # Explicit check for .jl extensions
    # Modules from zip will have .jl.from_zip to prevent loading via this method

    if !hasExt(fn, ".jl")
        return false
    end

    try
        fileMtime = stat(fn).mtime

        if fileMtime > get(loadedModulesTimes, fn, 0) || force
            loadedModules[fn] = include(fn)
            loadedModulesTimes[fn] = fileMtime

            return true

        else
            return false
        end

    catch e
        println(Base.stderr, "! Failed to load \"$fn\"")
        println(Base.stderr, e)

        return false
    end
end

hasModuleField(modul::Module, funcname::String) = isdefined(modul, Symbol(funcname))
hasModuleField(modul::String, funcname::String) = haskey(loadedModules, modul) && isdefined(loadedModules[modul], Symbol(funcname))

getModuleField(modul::Module, funcname::String) = getfield(modul, Symbol(funcname))
getModuleField(modul::String, funcname::String) = getfield(loadedModules[modul], Symbol(funcname))

function eventToModule(modul::Module, funcname::String, args...)
    if hasModuleField(modul, funcname)
        # Get function and call with arguments
        func = getModuleField(modul, funcname)

        if isa(func, Function) && applicable(func, args...)
            try
                res = func(args...)

                return res

            catch e
                # Error running the function
                println(Base.stderr, "Exception running function $funcname for $modul")

                for (exc, bt) in Base.catch_stack()
                    showerror(Base.stderr, exc, bt)
                    println(Base.stderr, "")
                end
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

eventToModule(v::Nothing, funcname::String, args...) = false

function eventToModule(fn::String, funcname::String, args...)
    # Make sure the module is properly loaded
    # If it isn't we can just return nothing
    if haskey(loadedModules, fn)
        return eventToModule(loadedModules[fn], funcname, args...)
    end
end

function eventToModules(funcname::String, args...)
    for (filename, modul) in loadedModules
        moduleRes = eventToModule(modul, funcname, args...)

        # False and nothing as only return value means we are not handing it and it should be taken to another function
        if moduleRes == false || moduleRes === nothing
            continue
        end

        return moduleRes
    end

    return false
end

function eventToModules(moduleNames::Array{String, 1}, funcname::String, args...)
    for moduleName in moduleNames
        moduleRes = eventToModule(moduleName, funcname, args...)

        # False and nothing as only return value means we are not handing it and it should be taken to another function
        if moduleRes == false || moduleRes === nothing
            continue
        end

        return moduleRes
    end

    return false
end