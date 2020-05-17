abstract type Snapshot end

mutable struct HistoryTimeline
    snapshots::Array{Snapshot, 1}
    index::Int
    skip::Bool

    HistoryTimeline(snapshots::Array{Snapshot, 1}=Snapshot[], index::Int=length(snapshots)) = new(snapshots, index, false)
end

function Base.push!(history::HistoryTimeline, snapshot::Snapshot)
    if history.index < length(history.snapshots)
        history.snapshots = history.snapshots[1:history.index]
    end

    push!(history.snapshots, snapshot)
    history.index += 1
end

function Base.pop!(history::HistoryTimeline)
    res = history.snapshots[history.index]
    history.index -= 1

    return res
end