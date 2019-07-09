module EntityIds

using ..Ahorn, Maple

EntityTriggerType = Union{Maple.Entity, Maple.Trigger}

entityIdState = nothing
validIds = Ahorn.MultiRange()

# These types should be unsafe for getting new ids because of ridge gate/condition block
unsafeForReassign = Type[
    Strawberry,
    GoldenStrawberry,
    MemorialTextController,
    Key
]

function nextId()
    res, state = entityIdState === nothing ? iterate(validIds) : iterate(validIds, entityIdState)
    global entityIdState = state

    return res
end

function getUsedIds(map::Maple.Map)
    usedIds = Int[]

    for room in map.rooms
        append!(usedIds, Int.(getfield.(room.entities, :id)))
        append!(usedIds, Int.(getfield.(room.triggers, :id)))
    end

    return usedIds
end

function groupByIds(map::Maple.Map)
    res = Dict{Int, Array{EntityTriggerType, 1}}()

    for room in map.rooms
        for targets in [room.triggers, room.entities]
            for target in targets
                id = Int(target.id)

                get!(Array{EntityTriggerType, 1}, res, id)
                push!(res[id], target)
            end
        end
    end

    return res
end

function attemptIdFixing(map::Maple.Map, idGroupDict=groupByIds(map), force::Bool=false)
    success = true
    reassigned = 0

    for (id, targets) in idGroupDict
        if length(targets) > 1
            unsafeCount = 0

            for (i, target) in enumerate(targets)
                unsafeTargets = Bool[typeof(target) in unsafeForReassign for target in targets]
                unsafeCount = sum(unsafeTargets)

                if force
                    if i != 1
                        target.id = nextId()
                        reassigned += 1
                    end

                else
                    if unsafeCount > 0 && !unsafeTargets[i]
                        target.id = nextId()
                        reassigned += 1

                    elseif unsafeCount == 0 && i != 1 
                        target.id = nextId()
                        reassigned += 1
                    end
                end
            end

            if unsafeCount > 1 && !force
                success = false
            end
        end
    end

    return success, reassigned
end

function getValidIdRanges(map::Maple.Map)
    usedIds = getUsedIds(map)
    sortedIds = sort(usedIds)

    gaps = UnitRange{Int}[]
    prev = -1

    for v in sortedIds
        if v !== prev && v - 1 !== prev
            push!(gaps, prev + 1:v - 1)
        end

        prev = v
    end

    push!(gaps, prev + 1:typemax(Int))

    return Ahorn.MultiRange(gaps)
end

function updateValidIds(map::Maple.Map)
    global validIds = getValidIdRanges(map)
    global entityIdState = nothing
end

end