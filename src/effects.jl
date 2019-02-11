function canFgBg(effect::Maple.Effect)
    return true, true
end

function editingOptions(effect::Maple.Effect)
    return Dict{String, Any}()
end

function registerPlacements!(placements::Array{Type{Maple.Effect{T}} where T, 1}, loaded::Array{String, 1})
    empty!(placements)

    for modul in loaded
        if hasModuleField(modul, "placements")
            res = getModuleField(modul, "placements")

            if isa(res, Array)
                append!(placements, res)

            else
                push!(placements, res)
            end
        end
    end
end

const loadedEffects = joinpath.(abs"effects", readdir(abs"effects"))
loadModule.(loadedEffects)
const effectPlacements = Array{Type{Maple.Effect{T}} where T, 1}()