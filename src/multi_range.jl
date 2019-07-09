struct MultiRange
    ranges::Array{UnitRange, 1}

    MultiRange(args...) = new([args...])
    MultiRange(ranges::Array{UnitRange{T}, 1}) where T = new(ranges)
end

function Base.iterate(mr::MultiRange)
    if isempty(mr.ranges)
        return nothing

    else
        res, state = iterate(mr.ranges[1])

        return res, (state, 1)
    end
end

function Base.iterate(mr::MultiRange, state::Tuple{Int, Int})
    rangeState, index = state
    iter = iterate(mr.ranges[index], rangeState)

    if iter === nothing
        if length(mr.ranges) >= index + 1
            res, state = iterate(mr.ranges[index + 1])

            return res, (state, index + 1)

        else
            return nothing
        end

    else
        res, state = iter

        return res, (state, index)
    end
end