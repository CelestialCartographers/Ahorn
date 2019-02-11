mutable struct JobQueue
    func
    itr
    state::Union{Integer, Nothing}

    JobQueue(f, itr) = new(f, itr, nothing)
end

# Returns true if there was a return value.
function process(q::JobQueue)
    y = q.state === nothing ? iterate(q.itr) : iterate(q.itr, q.state)
    y === nothing && return false
    q.func(y[1])
    q.state = y[2]::Integer
    
    return true
end