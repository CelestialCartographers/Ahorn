function canFgBg(effect::Maple.Effect)
    return true, true
end

editingOptions(entity::Maple.Effect) = Dict{String, Any}()
editingIgnored(entity::Maple.Effect) = String[]
editingOrder(entity::Maple.Effect) = String[
    "name", "only", "exclude", "tag",
    "flag", "notflag"
]

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
const effectPlacements = Array{Type{Maple.Effect{T}} where T, 1}()